// PrepPilot — verify-platform Edge Function.
//
// Fetches a user's REAL stats from LeetCode / Codeforces / AtCoder /
// GeeksforGeeks / CodeChef (problem solving) and GitHub (development), checks a
// one-time ownership token the user placed in their profile, and writes the
// numbers with the SERVICE ROLE so clients can never fake them.
//
// GitHub commits/PRs/issues need a token: set the GITHUB_TOKEN function secret
// (a classic PAT, no scopes needed for public data). Without it, GitHub falls
// back to REST + the public contributions graph (contributions/stars/repos only).
//
// Deploy:  supabase functions deploy verify-platform
//   (secret) supabase secrets set GITHUB_TOKEN=ghp_xxx   [optional but recommended]

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

const DAY = 86400;

interface Contest {
  contest: string;
  rank: number | null;
  rating: number | null;
  held_at: string | null;
}

interface Fetched {
  solved: number;
  rating: number;
  streak: number;
  profileText: string; // where we look for the ownership token
  maxStreak?: number;
  activeDays?: number;
  daily?: Record<string, number>; // "YYYY-MM-DD" -> count
  // Development (GitHub) stats.
  repos?: number;
  stars?: number;
  contributions?: number;
  commits?: number;
  prs?: number;
  issues?: number;
  languages?: Record<string, number>;
  contests?: Contest[];
}

// Compute current + max streak and active-day count from a {unixDaySeconds: n} map.
function streaksFromDays(activeDaySecs: Set<number>) {
  const days = [...activeDaySecs].sort((a, b) => a - b);
  const activeDays = days.length;
  let maxStreak = 0;
  let run = 0;
  let prev = 0;
  for (const d of days) {
    run = prev && d - prev === DAY ? run + 1 : 1;
    if (run > maxStreak) maxStreak = run;
    prev = d;
  }
  // current streak: consecutive days ending today or yesterday
  let current = 0;
  let cur = Math.floor(Date.now() / 1000 / DAY) * DAY;
  if (!activeDaySecs.has(cur)) cur -= DAY;
  while (activeDaySecs.has(cur)) {
    current++;
    cur -= DAY;
  }
  return { current, maxStreak, activeDays };
}

function isoDay(unixSec: number): string {
  return new Date(unixSec * 1000).toISOString().slice(0, 10);
}

// ----------------------------------------------------------------- LeetCode
async function fetchLeetCode(handle: string): Promise<Fetched | null> {
  const query = `query($u:String!){
    matchedUser(username:$u){
      profile{ realName aboutMe }
      submitStats{ acSubmissionNum{ difficulty count } }
      userCalendar{ submissionCalendar }
    }
    userContestRanking(username:$u){ rating }
    userContestRankingHistory(username:$u){ attended rating ranking contest{ title startTime } }
  }`;
  const res = await fetch("https://leetcode.com/graphql", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Referer": "https://leetcode.com",
      "User-Agent": "Mozilla/5.0",
    },
    body: JSON.stringify({ query, variables: { u: handle } }),
  });
  if (!res.ok) return null;
  const data = await res.json();
  const u = data?.data?.matchedUser;
  if (!u) return null;
  const all = (u.submitStats?.acSubmissionNum ?? []).find(
    (x: { difficulty: string }) => x.difficulty === "All",
  );

  const daily: Record<string, number> = {};
  const activeSet = new Set<number>();
  try {
    const cal = JSON.parse(u.userCalendar?.submissionCalendar ?? "{}");
    for (const [k, v] of Object.entries(cal)) {
      const n = v as number;
      if (n > 0) {
        const sec = Number(k);
        activeSet.add(Math.floor(sec / DAY) * DAY);
        daily[isoDay(sec)] = n;
      }
    }
  } catch (_) { /* ignore */ }
  const { current, maxStreak, activeDays } = streaksFromDays(activeSet);

  const contests: Contest[] = [];
  for (const h of data?.data?.userContestRankingHistory ?? []) {
    if (h?.attended && h.contest) {
      contests.push({
        contest: h.contest.title,
        rank: h.ranking ?? null,
        rating: h.rating != null ? Math.round(h.rating) : null,
        held_at: h.contest.startTime
          ? new Date(h.contest.startTime * 1000).toISOString()
          : null,
      });
    }
  }

  return {
    solved: all?.count ?? 0,
    rating: Math.round(data?.data?.userContestRanking?.rating ?? 0),
    streak: current,
    maxStreak,
    activeDays,
    daily,
    contests,
    profileText: `${u.profile?.realName ?? ""} ${u.profile?.aboutMe ?? ""}`,
  };
}

// --------------------------------------------------------------- Codeforces
async function fetchCodeforces(handle: string): Promise<Fetched | null> {
  const infoRes = await fetch(
    `https://codeforces.com/api/user.info?handles=${encodeURIComponent(handle)}`,
  );
  if (!infoRes.ok) return null;
  const info = await infoRes.json();
  if (info.status !== "OK" || !info.result?.[0]) return null;
  const user = info.result[0];

  let solved = 0;
  const daily: Record<string, number> = {};
  const activeSet = new Set<number>();
  try {
    const stRes = await fetch(
      `https://codeforces.com/api/user.status?handle=${encodeURIComponent(handle)}`,
    );
    if (stRes.ok) {
      const st = await stRes.json();
      if (st.status === "OK") {
        const ok = new Set<string>();
        for (const sub of st.result) {
          const sec = sub.creationTimeSeconds ?? 0;
          if (sec) {
            const d = isoDay(sec);
            daily[d] = (daily[d] ?? 0) + 1;
            activeSet.add(Math.floor(sec / DAY) * DAY);
          }
          if (sub.verdict === "OK" && sub.problem) {
            ok.add(`${sub.problem.contestId ?? "x"}-${sub.problem.index}`);
          }
        }
        solved = ok.size;
      }
    }
  } catch (_) { /* keep 0 */ }
  const { current, maxStreak, activeDays } = streaksFromDays(activeSet);

  const contests: Contest[] = [];
  try {
    const rRes = await fetch(
      `https://codeforces.com/api/user.rating?handle=${encodeURIComponent(handle)}`,
    );
    if (rRes.ok) {
      const r = await rRes.json();
      if (r.status === "OK") {
        for (const c of r.result) {
          contests.push({
            contest: c.contestName,
            rank: c.rank ?? null,
            rating: c.newRating ?? null,
            held_at: c.ratingUpdateTimeSeconds
              ? new Date(c.ratingUpdateTimeSeconds * 1000).toISOString()
              : null,
          });
        }
      }
    }
  } catch (_) { /* ignore */ }

  return {
    solved,
    rating: user.rating ?? 0,
    streak: current,
    maxStreak,
    activeDays,
    daily,
    contests,
    profileText:
      `${user.firstName ?? ""} ${user.lastName ?? ""} ${user.organization ?? ""}`,
  };
}

// ------------------------------------------------------------------ AtCoder
async function fetchAtcoder(handle: string): Promise<Fetched | null> {
  const pRes = await fetch(`https://atcoder.jp/users/${encodeURIComponent(handle)}`, {
    headers: { "User-Agent": "Mozilla/5.0" },
  });
  if (!pRes.ok) return null;
  const profileText = await pRes.text();

  let solved = 0;
  try {
    const info = await fetch(
      `https://kenkoooo.com/atcoder/atcoder-api/v2/user_info?user=${encodeURIComponent(handle)}`,
    );
    if (info.ok) solved = (await info.json())?.accepted_count ?? 0;
  } catch (_) { /* keep 0 */ }

  let rating = 0;
  const contests: Contest[] = [];
  try {
    const hist = await fetch(
      `https://atcoder.jp/users/${encodeURIComponent(handle)}/history/json`,
    );
    if (hist.ok) {
      const h = await hist.json();
      if (Array.isArray(h)) {
        for (const c of h) {
          contests.push({
            contest: c.ContestName ?? c.ContestScreenName ?? "Contest",
            rank: c.Place ?? null,
            rating: c.NewRating ?? null,
            held_at: c.EndTime ?? null,
          });
        }
        if (h.length) rating = h[h.length - 1].NewRating ?? 0;
      }
    }
  } catch (_) { /* keep 0 */ }

  return { solved, rating, streak: 0, contests, profileText };
}

// ------------------------------------------------------------- GeeksforGeeks
async function fetchGeeksforgeeks(handle: string): Promise<Fetched | null> {
  const res = await fetch(
    `https://authapi.geeksforgeeks.org/api-get/user-profile-info/?handle=${encodeURIComponent(handle)}`,
    { headers: { "User-Agent": "Mozilla/5.0" } },
  );
  if (!res.ok) return null;
  const d = (await res.json())?.data;
  if (!d) return null;
  return {
    solved: d.total_problems_solved ?? 0,
    rating: 0,
    streak: d.pod_solved_current_streak ?? 0,
    maxStreak: d.pod_solved_longest_streak ?? 0,
    profileText: `${d.name ?? ""}`,
  };
}

// ---------------------------------------------------------------- CodeChef
async function fetchCodechef(handle: string): Promise<Fetched | null> {
  const res = await fetch(
    `https://www.codechef.com/users/${encodeURIComponent(handle)}`,
    { headers: { "User-Agent": "Mozilla/5.0" } },
  );
  if (!res.ok) return null;
  const html = await res.text();
  const name = html.match(/<h1 class="h2-style">([^<]+)<\/h1>/)?.[1] ?? "";
  if (!name) return null;
  const rating = parseInt(
    html.match(/class="rating-number">\s*([0-9]+)/)?.[1] ?? "0",
  );
  const solved = parseInt(
    html.match(/Total Problems Solved[^0-9]*([0-9]+)/)?.[1] ?? "0",
  );
  // Contest history from the embedded rating-data JS array.
  const contests: Contest[] = [];
  try {
    const m = html.match(/var all_rating = (\[.*?\]);/s);
    if (m) {
      for (const c of JSON.parse(m[1])) {
        contests.push({
          contest: c.name ?? c.code ?? "Contest",
          rank: c.rank ? parseInt(c.rank, 10) : null,
          rating: c.rating ? parseInt(c.rating, 10) : null,
          held_at: c.end_date ? new Date(c.end_date).toISOString() : null,
        });
      }
    }
  } catch (_) { /* ignore */ }
  return { solved, rating, streak: 0, contests, profileText: name };
}

// ---------------------------------------------------------------- GitHub (dev)
async function fetchGithub(handle: string): Promise<Fetched | null> {
  const gh = { "User-Agent": "PrepPilot", "Accept": "application/vnd.github+json" };
  const uRes = await fetch(`https://api.github.com/users/${encodeURIComponent(handle)}`, {
    headers: gh,
  });
  if (!uRes.ok) return null;
  const u = await uRes.json();

  // Repos → stars + language distribution.
  let stars = 0;
  const repos = u.public_repos ?? 0;
  const languages: Record<string, number> = {};
  try {
    const rRes = await fetch(
      `https://api.github.com/users/${encodeURIComponent(handle)}/repos?per_page=100&sort=pushed`,
      { headers: gh },
    );
    if (rRes.ok) {
      for (const x of await rRes.json()) {
        stars += x.stargazers_count ?? 0;
        if (x.language) languages[x.language] = (languages[x.language] ?? 0) + 1;
      }
    }
  } catch (_) { /* keep 0 */ }

  let contributions = 0;
  let commits = 0;
  let prs = 0;
  let issues = 0;
  let streak = 0;
  let maxStreak = 0;
  let activeDays = 0;
  const daily: Record<string, number> = {};

  const ghToken = Deno.env.get("GITHUB_TOKEN");
  if (ghToken) {
    // GraphQL: full contribution breakdown (commits/PRs/issues) + daily calendar.
    try {
      const q = `query($u:String!){ user(login:$u){ contributionsCollection{
        totalCommitContributions totalPullRequestContributions totalIssueContributions
        contributionCalendar{ totalContributions weeks{ contributionDays{ date contributionCount } } }
      } } }`;
      const gRes = await fetch("https://api.github.com/graphql", {
        method: "POST",
        headers: { "Authorization": `bearer ${ghToken}`, "Content-Type": "application/json", "User-Agent": "PrepPilot" },
        body: JSON.stringify({ query: q, variables: { u: handle } }),
      });
      if (gRes.ok) {
        const c = (await gRes.json())?.data?.user?.contributionsCollection;
        if (c) {
          commits = c.totalCommitContributions ?? 0;
          prs = c.totalPullRequestContributions ?? 0;
          issues = c.totalIssueContributions ?? 0;
          contributions = c.contributionCalendar?.totalContributions ?? 0;
          const activeSet = new Set<number>();
          for (const w of c.contributionCalendar?.weeks ?? []) {
            for (const dd of w.contributionDays ?? []) {
              if ((dd.contributionCount ?? 0) > 0) {
                daily[dd.date] = dd.contributionCount;
                activeSet.add(Math.floor(new Date(dd.date).getTime() / 1000 / DAY) * DAY);
              }
            }
          }
          const s = streaksFromDays(activeSet);
          streak = s.current;
          maxStreak = s.maxStreak;
          activeDays = s.activeDays;
        }
      }
    } catch (_) { /* fall through to REST below */ }
  }

  if (contributions === 0) {
    // Fallback: public contributions graph (total + streak only).
    try {
      const cRes = await fetch(
        `https://github.com/users/${encodeURIComponent(handle)}/contributions`,
        { headers: { "User-Agent": "Mozilla/5.0" } },
      );
      if (cRes.ok) {
        const html = await cRes.text();
        for (const m of html.matchAll(/>([0-9,]+) contributions? on/g)) {
          contributions += parseInt(m[1].replace(/,/g, ""), 10) || 0;
        }
        const activeSet = new Set<number>();
        for (const m of html.matchAll(/<td[^>]*data-date="(\d{4}-\d\d-\d\d)"[^>]*>/g)) {
          const lv = /data-level="([1-9])"/.exec(m[0]);
          if (lv) activeSet.add(Math.floor(new Date(m[1]).getTime() / 1000 / DAY) * DAY);
        }
        const s = streaksFromDays(activeSet);
        streak = s.current;
        maxStreak = s.maxStreak;
        activeDays = s.activeDays;
      }
    } catch (_) { /* keep 0 */ }
  }

  return {
    solved: 0,
    rating: 0,
    streak,
    maxStreak,
    activeDays,
    daily,
    profileText: `${u.name ?? ""} ${u.bio ?? ""}`,
    repos,
    stars,
    contributions,
    commits,
    prs,
    issues,
    languages,
  };
}

const FETCHERS: Record<string, (h: string) => Promise<Fetched | null>> = {
  leetcode: fetchLeetCode,
  codeforces: fetchCodeforces,
  atcoder: fetchAtcoder,
  geeksforgeeks: fetchGeeksforgeeks,
  codechef: fetchCodechef,
  github: fetchGithub,
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "POST only" }, 405);

  const authHeader = req.headers.get("Authorization") ?? "";
  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: userData, error: userErr } = await userClient.auth.getUser();
  if (userErr || !userData?.user) return json({ error: "Not signed in" }, 401);
  const uid = userData.user.id;

  let body: { platform?: string; handle?: string };
  try {
    body = await req.json();
  } catch (_) {
    return json({ error: "Bad JSON" }, 400);
  }
  const platform = (body.platform ?? "").toLowerCase();
  const handle = (body.handle ?? "").trim();
  const fetcher = FETCHERS[platform];
  if (!handle || !fetcher) {
    return json({
      error: "platform must be one of " + Object.keys(FETCHERS).join("|") +
        ", handle required",
    }, 400);
  }

  const admin = createClient(supabaseUrl, serviceKey);

  const { data: link } = await admin
    .from("platform_links")
    .select("verify_token")
    .eq("user_id", uid)
    .eq("platform", platform)
    .maybeSingle();
  const token: string | null = link?.verify_token ?? null;

  const { data: existing } = await admin
    .from("platform_stats")
    .select("verified")
    .eq("user_id", uid)
    .eq("platform", platform)
    .maybeSingle();
  const alreadyVerified = existing?.verified === true;

  const fetched = await fetcher(handle);
  if (!fetched) return json({ error: "Could not reach platform or handle not found" }, 502);

  const tokenPresent =
    !!token && fetched.profileText.toLowerCase().includes(token.toLowerCase());
  const verified = tokenPresent || alreadyVerified;

  if (!verified) {
    return json({
      verified: false,
      solved: fetched.solved,
      rating: fetched.rating,
      streak: fetched.streak,
      error: "Token not found in your profile yet",
    });
  }

  await admin.from("platform_stats").upsert({
    user_id: uid,
    platform,
    verified: true,
    solved: fetched.solved,
    rating: fetched.rating,
    streak: fetched.streak,
    max_streak: fetched.maxStreak ?? null,
    active_days: fetched.activeDays ?? null,
    daily: fetched.daily ?? null,
    repos: fetched.repos ?? null,
    stars: fetched.stars ?? null,
    contributions: fetched.contributions ?? null,
    commits: fetched.commits ?? null,
    prs: fetched.prs ?? null,
    issues: fetched.issues ?? null,
    languages: fetched.languages ?? null,
    synced_at: new Date().toISOString(),
  });

  // Refresh contest history for this platform (delete + insert).
  if (fetched.contests && fetched.contests.length) {
    await admin.from("contest_history").delete().eq("user_id", uid).eq("platform", platform);
    const rows = fetched.contests.slice(-100).map((c) => ({
      user_id: uid,
      platform,
      contest: c.contest.slice(0, 200),
      rank: c.rank,
      rating: c.rating,
      held_at: c.held_at,
    }));
    // Dedup by contest name (pk is user+platform+contest).
    const seen = new Set<string>();
    const uniq = rows.filter((r) => {
      if (seen.has(r.contest)) return false;
      seen.add(r.contest);
      return true;
    });
    if (uniq.length) await admin.from("contest_history").insert(uniq);
  }

  return json({
    verified: true,
    solved: fetched.solved,
    rating: fetched.rating,
    streak: fetched.streak,
    contributions: fetched.contributions ?? 0,
    commits: fetched.commits ?? 0,
    prs: fetched.prs ?? 0,
    issues: fetched.issues ?? 0,
  });
});
