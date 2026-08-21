import 'seed_models.dart';

/// All built-in study content. Idempotently seeded by slug, so editing this
/// list and shipping an update safely adds new items without touching user
/// progress.
const List<SeedSheet> kSeedSheets = [
  // ======================= DSA ==========================================
  SeedSheet(
    slug: 'dsa-essential',
    title: 'DSA Essentials',
    category: 'dsa',
    description: 'A focused, interview-ready path through core data structures & algorithms.',
    source: 'Curated (Blind 75 / Striver style)',
    topics: [
      SeedTopic(slug: 'arrays', title: 'Arrays & Hashing', items: [
        SeedItem(slug: 'lc-two-sum', title: 'Two Sum', difficulty: 'easy', url: 'https://leetcode.com/problems/two-sum/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-best-time-to-buy-and-sell-stock', title: 'Best Time to Buy and Sell Stock', difficulty: 'easy', url: 'https://leetcode.com/problems/best-time-to-buy-and-sell-stock/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-maximum-subarray', title: 'Maximum Subarray (Kadane)', difficulty: 'medium', url: 'https://leetcode.com/problems/maximum-subarray/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-product-of-array-except-self', title: 'Product of Array Except Self', difficulty: 'medium', url: 'https://leetcode.com/problems/product-of-array-except-self/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-merge-intervals', title: 'Merge Intervals', difficulty: 'medium', url: 'https://leetcode.com/problems/merge-intervals/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-set-matrix-zeroes', title: 'Set Matrix Zeroes', difficulty: 'medium', url: 'https://leetcode.com/problems/set-matrix-zeroes/', platform: 'LeetCode', tags: 'dsa'),
      ]),
      SeedTopic(slug: 'two-pointers', title: 'Two Pointers', items: [
        SeedItem(slug: 'lc-valid-palindrome', title: 'Valid Palindrome', difficulty: 'easy', url: 'https://leetcode.com/problems/valid-palindrome/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-3sum', title: '3Sum', difficulty: 'medium', url: 'https://leetcode.com/problems/3sum/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-container-with-most-water', title: 'Container With Most Water', difficulty: 'medium', url: 'https://leetcode.com/problems/container-with-most-water/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-trapping-rain-water', title: 'Trapping Rain Water', difficulty: 'hard', url: 'https://leetcode.com/problems/trapping-rain-water/', platform: 'LeetCode', tags: 'dsa'),
      ]),
      SeedTopic(slug: 'binary-search', title: 'Binary Search', items: [
        SeedItem(slug: 'lc-binary-search', title: 'Binary Search', difficulty: 'easy', url: 'https://leetcode.com/problems/binary-search/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-search-in-rotated-sorted-array', title: 'Search in Rotated Sorted Array', difficulty: 'medium', url: 'https://leetcode.com/problems/search-in-rotated-sorted-array/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-find-minimum-in-rotated-sorted-array', title: 'Find Minimum in Rotated Sorted Array', difficulty: 'medium', url: 'https://leetcode.com/problems/find-minimum-in-rotated-sorted-array/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-koko-eating-bananas', title: 'Koko Eating Bananas', difficulty: 'medium', url: 'https://leetcode.com/problems/koko-eating-bananas/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-median-of-two-sorted-arrays', title: 'Median of Two Sorted Arrays', difficulty: 'hard', url: 'https://leetcode.com/problems/median-of-two-sorted-arrays/', platform: 'LeetCode', tags: 'dsa'),
      ]),
      SeedTopic(slug: 'strings', title: 'Strings & Sliding Window', items: [
        SeedItem(slug: 'lc-valid-anagram', title: 'Valid Anagram', difficulty: 'easy', url: 'https://leetcode.com/problems/valid-anagram/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-group-anagrams', title: 'Group Anagrams', difficulty: 'medium', url: 'https://leetcode.com/problems/group-anagrams/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-longest-substring-without-repeating-characters', title: 'Longest Substring Without Repeating Characters', difficulty: 'medium', url: 'https://leetcode.com/problems/longest-substring-without-repeating-characters/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-longest-palindromic-substring', title: 'Longest Palindromic Substring', difficulty: 'medium', url: 'https://leetcode.com/problems/longest-palindromic-substring/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-minimum-window-substring', title: 'Minimum Window Substring', difficulty: 'hard', url: 'https://leetcode.com/problems/minimum-window-substring/', platform: 'LeetCode', tags: 'dsa'),
      ]),
      SeedTopic(slug: 'linked-list', title: 'Linked List', items: [
        SeedItem(slug: 'lc-reverse-linked-list', title: 'Reverse Linked List', difficulty: 'easy', url: 'https://leetcode.com/problems/reverse-linked-list/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-merge-two-sorted-lists', title: 'Merge Two Sorted Lists', difficulty: 'easy', url: 'https://leetcode.com/problems/merge-two-sorted-lists/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-linked-list-cycle', title: 'Linked List Cycle', difficulty: 'easy', url: 'https://leetcode.com/problems/linked-list-cycle/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-remove-nth-node-from-end-of-list', title: 'Remove Nth Node From End of List', difficulty: 'medium', url: 'https://leetcode.com/problems/remove-nth-node-from-end-of-list/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-lru-cache', title: 'LRU Cache', difficulty: 'medium', url: 'https://leetcode.com/problems/lru-cache/', platform: 'LeetCode', tags: 'dsa'),
      ]),
      SeedTopic(slug: 'stacks-queues', title: 'Stacks & Queues', items: [
        SeedItem(slug: 'lc-valid-parentheses', title: 'Valid Parentheses', difficulty: 'easy', url: 'https://leetcode.com/problems/valid-parentheses/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-min-stack', title: 'Min Stack', difficulty: 'medium', url: 'https://leetcode.com/problems/min-stack/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-daily-temperatures', title: 'Daily Temperatures', difficulty: 'medium', url: 'https://leetcode.com/problems/daily-temperatures/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-largest-rectangle-in-histogram', title: 'Largest Rectangle in Histogram', difficulty: 'hard', url: 'https://leetcode.com/problems/largest-rectangle-in-histogram/', platform: 'LeetCode', tags: 'dsa'),
      ]),
      SeedTopic(slug: 'trees', title: 'Trees', items: [
        SeedItem(slug: 'lc-maximum-depth-of-binary-tree', title: 'Maximum Depth of Binary Tree', difficulty: 'easy', url: 'https://leetcode.com/problems/maximum-depth-of-binary-tree/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-invert-binary-tree', title: 'Invert Binary Tree', difficulty: 'easy', url: 'https://leetcode.com/problems/invert-binary-tree/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-diameter-of-binary-tree', title: 'Diameter of Binary Tree', difficulty: 'easy', url: 'https://leetcode.com/problems/diameter-of-binary-tree/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-binary-tree-level-order-traversal', title: 'Binary Tree Level Order Traversal', difficulty: 'medium', url: 'https://leetcode.com/problems/binary-tree-level-order-traversal/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-validate-binary-search-tree', title: 'Validate Binary Search Tree', difficulty: 'medium', url: 'https://leetcode.com/problems/validate-binary-search-tree/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-lowest-common-ancestor-of-a-binary-search-tree', title: 'Lowest Common Ancestor of a BST', difficulty: 'medium', url: 'https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-search-tree/', platform: 'LeetCode', tags: 'dsa'),
      ]),
      SeedTopic(slug: 'graphs', title: 'Graphs', items: [
        SeedItem(slug: 'lc-number-of-islands', title: 'Number of Islands', difficulty: 'medium', url: 'https://leetcode.com/problems/number-of-islands/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-clone-graph', title: 'Clone Graph', difficulty: 'medium', url: 'https://leetcode.com/problems/clone-graph/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-course-schedule', title: 'Course Schedule (Topo Sort)', difficulty: 'medium', url: 'https://leetcode.com/problems/course-schedule/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-rotting-oranges', title: 'Rotting Oranges (BFS)', difficulty: 'medium', url: 'https://leetcode.com/problems/rotting-oranges/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-word-ladder', title: 'Word Ladder', difficulty: 'hard', url: 'https://leetcode.com/problems/word-ladder/', platform: 'LeetCode', tags: 'dsa'),
      ]),
      SeedTopic(slug: 'dynamic-programming', title: 'Dynamic Programming', items: [
        SeedItem(slug: 'lc-climbing-stairs', title: 'Climbing Stairs', difficulty: 'easy', url: 'https://leetcode.com/problems/climbing-stairs/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-house-robber', title: 'House Robber', difficulty: 'medium', url: 'https://leetcode.com/problems/house-robber/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-coin-change', title: 'Coin Change', difficulty: 'medium', url: 'https://leetcode.com/problems/coin-change/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-longest-increasing-subsequence', title: 'Longest Increasing Subsequence', difficulty: 'medium', url: 'https://leetcode.com/problems/longest-increasing-subsequence/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-longest-common-subsequence', title: 'Longest Common Subsequence', difficulty: 'medium', url: 'https://leetcode.com/problems/longest-common-subsequence/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-edit-distance', title: 'Edit Distance', difficulty: 'hard', url: 'https://leetcode.com/problems/edit-distance/', platform: 'LeetCode', tags: 'dsa'),
      ]),
      SeedTopic(slug: 'greedy-backtracking', title: 'Greedy & Backtracking', items: [
        SeedItem(slug: 'lc-jump-game', title: 'Jump Game', difficulty: 'medium', url: 'https://leetcode.com/problems/jump-game/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-subsets', title: 'Subsets', difficulty: 'medium', url: 'https://leetcode.com/problems/subsets/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-permutations', title: 'Permutations', difficulty: 'medium', url: 'https://leetcode.com/problems/permutations/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-combination-sum', title: 'Combination Sum', difficulty: 'medium', url: 'https://leetcode.com/problems/combination-sum/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-word-search', title: 'Word Search', difficulty: 'medium', url: 'https://leetcode.com/problems/word-search/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-n-queens', title: 'N-Queens', difficulty: 'hard', url: 'https://leetcode.com/problems/n-queens/', platform: 'LeetCode', tags: 'dsa'),
      ]),
      SeedTopic(slug: 'heap-trie-bits', title: 'Heaps, Tries & Bit Manipulation', items: [
        SeedItem(slug: 'lc-single-number', title: 'Single Number', difficulty: 'easy', url: 'https://leetcode.com/problems/single-number/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-counting-bits', title: 'Counting Bits', difficulty: 'easy', url: 'https://leetcode.com/problems/counting-bits/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-kth-largest-element-in-an-array', title: 'Kth Largest Element in an Array', difficulty: 'medium', url: 'https://leetcode.com/problems/kth-largest-element-in-an-array/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-top-k-frequent-elements', title: 'Top K Frequent Elements', difficulty: 'medium', url: 'https://leetcode.com/problems/top-k-frequent-elements/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-implement-trie-prefix-tree', title: 'Implement Trie (Prefix Tree)', difficulty: 'medium', url: 'https://leetcode.com/problems/implement-trie-prefix-tree/', platform: 'LeetCode', tags: 'dsa'),
        SeedItem(slug: 'lc-find-median-from-data-stream', title: 'Find Median from Data Stream', difficulty: 'hard', url: 'https://leetcode.com/problems/find-median-from-data-stream/', platform: 'LeetCode', tags: 'dsa'),
      ]),
    ],
  ),

  // ======================= CORE CS ======================================
  SeedSheet(
    slug: 'core-cs',
    title: 'CS Core Subjects',
    category: 'core',
    description: 'The theory interviewers love: OS, DBMS, Networks and OOP.',
    topics: [
      SeedTopic(slug: 'os', title: 'Operating Systems', items: [
        SeedItem(slug: 'os-process-thread', title: 'Process vs Thread', difficulty: 'easy', platform: 'Concept'),
        SeedItem(slug: 'os-scheduling', title: 'CPU Scheduling Algorithms', platform: 'Concept'),
        SeedItem(slug: 'os-deadlock', title: 'Deadlock & Coffman Conditions', platform: 'Concept'),
        SeedItem(slug: 'os-sync', title: 'Semaphores, Mutex & Critical Section', platform: 'Concept'),
        SeedItem(slug: 'os-memory', title: 'Paging, Segmentation & Virtual Memory', difficulty: 'hard', platform: 'Concept'),
        SeedItem(slug: 'os-page-replace', title: 'Page Replacement Algorithms', platform: 'Concept'),
      ]),
      SeedTopic(slug: 'dbms', title: 'DBMS', items: [
        SeedItem(slug: 'dbms-normalization', title: 'Normalization (1NF → BCNF)', platform: 'Concept'),
        SeedItem(slug: 'dbms-acid', title: 'ACID Properties', difficulty: 'easy', platform: 'Concept'),
        SeedItem(slug: 'dbms-indexing', title: 'Indexing & B+ Trees', difficulty: 'hard', platform: 'Concept'),
        SeedItem(slug: 'dbms-joins', title: 'Joins & Set Operations', platform: 'Concept'),
        SeedItem(slug: 'dbms-transactions', title: 'Transactions & Concurrency Control', difficulty: 'hard', platform: 'Concept'),
        SeedItem(slug: 'dbms-sql-nosql', title: 'SQL vs NoSQL', difficulty: 'easy', platform: 'Concept'),
      ]),
      SeedTopic(slug: 'cn', title: 'Computer Networks', items: [
        SeedItem(slug: 'cn-models', title: 'OSI vs TCP/IP Model', difficulty: 'easy', platform: 'Concept'),
        SeedItem(slug: 'cn-tcp-udp', title: 'TCP vs UDP', difficulty: 'easy', platform: 'Concept'),
        SeedItem(slug: 'cn-http', title: 'HTTP/HTTPS & Status Codes', platform: 'Concept'),
        SeedItem(slug: 'cn-dns', title: 'DNS Resolution', platform: 'Concept'),
        SeedItem(slug: 'cn-subnetting', title: 'IP Addressing & Subnetting', difficulty: 'hard', platform: 'Concept'),
      ]),
      SeedTopic(slug: 'oop', title: 'OOP', items: [
        SeedItem(slug: 'oop-pillars', title: 'Four Pillars of OOP', difficulty: 'easy', platform: 'Concept'),
        SeedItem(slug: 'oop-solid', title: 'SOLID Principles', platform: 'Concept'),
        SeedItem(slug: 'oop-composition', title: 'Composition vs Inheritance', platform: 'Concept'),
        SeedItem(slug: 'oop-polymorphism', title: 'Overloading vs Overriding', platform: 'Concept'),
      ]),
    ],
  ),

  // ======================= APTITUDE =====================================
  SeedSheet(
    slug: 'aptitude',
    title: 'Aptitude & Reasoning',
    category: 'aptitude',
    description: 'The gatekeeper round for most service & mass-recruiter drives.',
    topics: [
      SeedTopic(slug: 'quant', title: 'Quantitative Aptitude', items: [
        SeedItem(slug: 'apt-percentages', title: 'Percentages', difficulty: 'easy', platform: 'Practice'),
        SeedItem(slug: 'apt-profit-loss', title: 'Profit & Loss', difficulty: 'easy', platform: 'Practice'),
        SeedItem(slug: 'apt-time-work', title: 'Time & Work', platform: 'Practice'),
        SeedItem(slug: 'apt-tsd', title: 'Time, Speed & Distance', platform: 'Practice'),
        SeedItem(slug: 'apt-ratio', title: 'Ratio & Proportion', difficulty: 'easy', platform: 'Practice'),
        SeedItem(slug: 'apt-pnc', title: 'Permutations & Combinations', difficulty: 'hard', platform: 'Practice'),
        SeedItem(slug: 'apt-probability', title: 'Probability', difficulty: 'hard', platform: 'Practice'),
      ]),
      SeedTopic(slug: 'logical', title: 'Logical Reasoning', items: [
        SeedItem(slug: 'apt-series', title: 'Number & Letter Series', difficulty: 'easy', platform: 'Practice'),
        SeedItem(slug: 'apt-blood-relations', title: 'Blood Relations', platform: 'Practice'),
        SeedItem(slug: 'apt-seating', title: 'Seating Arrangement', platform: 'Practice'),
        SeedItem(slug: 'apt-syllogism', title: 'Syllogisms', platform: 'Practice'),
        SeedItem(slug: 'apt-coding-decoding', title: 'Coding-Decoding', difficulty: 'easy', platform: 'Practice'),
      ]),
      SeedTopic(slug: 'verbal', title: 'Verbal Ability', items: [
        SeedItem(slug: 'apt-rc', title: 'Reading Comprehension', platform: 'Practice'),
        SeedItem(slug: 'apt-sentence-correction', title: 'Sentence Correction', platform: 'Practice'),
        SeedItem(slug: 'apt-para-jumbles', title: 'Para Jumbles', platform: 'Practice'),
      ]),
    ],
  ),

  // ======================= SYSTEM DESIGN ================================
  SeedSheet(
    slug: 'system-design',
    title: 'System Design Basics',
    category: 'system',
    description: 'Enough HLD/LLD to handle product-based design rounds.',
    topics: [
      SeedTopic(slug: 'hld', title: 'High-Level Design', items: [
        SeedItem(slug: 'sd-scalability', title: 'Scalability: Vertical vs Horizontal', difficulty: 'easy', platform: 'Concept'),
        SeedItem(slug: 'sd-load-balancing', title: 'Load Balancing', platform: 'Concept'),
        SeedItem(slug: 'sd-caching', title: 'Caching Strategies', platform: 'Concept'),
        SeedItem(slug: 'sd-sharding', title: 'Database Sharding & Replication', difficulty: 'hard', platform: 'Concept'),
        SeedItem(slug: 'sd-cap', title: 'CAP Theorem', platform: 'Concept'),
        SeedItem(slug: 'sd-mq', title: 'Message Queues & Async Processing', platform: 'Concept'),
      ]),
      SeedTopic(slug: 'lld', title: 'Low-Level Design', items: [
        SeedItem(slug: 'sd-parking-lot', title: 'Design a Parking Lot', platform: 'Concept'),
        SeedItem(slug: 'sd-patterns', title: 'Common Design Patterns', platform: 'Concept'),
      ]),
    ],
  ),

  // ======================= INTERVIEW ====================================
  SeedSheet(
    slug: 'interview-hr',
    title: 'HR & Behavioural',
    category: 'interview',
    description: 'Nail the final round — structure your stories with STAR.',
    topics: [
      SeedTopic(slug: 'hr', title: 'HR Questions', items: [
        SeedItem(slug: 'hr-tell-me', title: 'Tell me about yourself', difficulty: 'easy', platform: 'Prep'),
        SeedItem(slug: 'hr-strengths', title: 'Strengths & Weaknesses', difficulty: 'easy', platform: 'Prep'),
        SeedItem(slug: 'hr-why-company', title: 'Why this company / role?', platform: 'Prep'),
        SeedItem(slug: 'hr-5-years', title: 'Where do you see yourself in 5 years?', platform: 'Prep'),
      ]),
      SeedTopic(slug: 'behavioural', title: 'Behavioural', items: [
        SeedItem(slug: 'beh-star', title: 'The STAR Method', difficulty: 'easy', platform: 'Prep'),
        SeedItem(slug: 'beh-conflict', title: 'Handling Conflict / Disagreement', platform: 'Prep'),
        SeedItem(slug: 'beh-failure', title: 'Tell me about a failure', platform: 'Prep'),
        SeedItem(slug: 'beh-leadership', title: 'A time you showed leadership', platform: 'Prep'),
      ]),
    ],
  ),
];
