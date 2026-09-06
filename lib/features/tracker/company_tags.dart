/// Canonical employer names for the `companies` tags the content carries.
///
/// The two company-tagged sheets were imported from a source that had already
/// damaged the tag list, and the damage has to be undone at read time or the
/// "By company" screen lists things that are not companies:
///
///  * **multi-word employers were split on whitespace and then sorted
///    alphabetically**, so "Goldman Sachs" arrives as the separate tags
///    `goldman` and `sachs`, "Morgan Stanley" as `morgan` and `stanley`, "MAQ
///    Software" as `maq` and `software`, and so on. Sorting destroyed the
///    adjacency, so the fragments cannot be rejoined positionally — but the
///    halves always co-occur on the same problem (checked: 21/22 for
///    goldman/sachs, 24/25 for morgan/stanley, 14/14 for oyo/rooms, 18/18 for
///    maq/software), so mapping every fragment to the same canonical name and
///    collecting into a Set yields exactly one correct entry per employer.
///  * **some rows use a non-breaking space as the separator** instead of a
///    comma, leaving five-employer runs glued into one tag.
///  * a few tags are not employers at all — `interview`/`qs` (always paired),
///    and a stray row of topic tags (`arrays`, `dynamic`, `programming`).
///  * assorted typos (`amazoon`, `micorsoft`, `fipkart`) and stray `+` marks.
///
/// Normalising here rather than rewriting the assets keeps the imported content
/// untouched and needs no reseed, and puts the reasoning next to the tables.
class CompanyTags {
  const CompanyTags._();

  /// Fragments, typos and display forms mapped to one canonical name. Keys are
  /// lower-case; anything not listed is simply title-cased.
  static const Map<String, String> _canonical = {
    // Multi-word employers the importer split apart.
    'goldman': 'Goldman Sachs',
    'sachs': 'Goldman Sachs',
    'goldman sachs': 'Goldman Sachs',
    'morgan': 'Morgan Stanley',
    'stanley': 'Morgan Stanley',
    'rooms': 'OYO',
    'room': 'OYO',
    'oyo': 'OYO',
    'maq': 'MAQ Software',
    'software': 'MAQ Software',
    'cabs': 'Ola',
    'ola': 'Ola',
    'de': 'D. E. Shaw',
    'shaw': 'D. E. Shaw',
    'd-e-shaw': 'D. E. Shaw',
    'times': 'Times Internet',
    'internet': 'Times Internet',
    'juniper': 'Juniper Networks',
    'networks': 'Juniper Networks',
    'societe': 'Societe Generale',
    'generale': 'Societe Generale',
    'american': 'American Express',
    'express': 'American Express',
    'now': 'ServiceNow',
    'service': 'ServiceNow',
    'oxigen': 'Oxigen Wallet',
    'wallet': 'Oxigen Wallet',
    'fidelity': 'Fidelity International',
    'international': 'Fidelity International',
    'streamoid': 'Streamoid Technologies',
    '24*7': '24/7 Innovation Labs',

    // Typos carried in from the source.
    'amazoon': 'Amazon',
    'amaxon': 'Amazon',
    'micorsoft': 'Microsoft',
    'fipkart': 'Flipkart',
    'flipkar': 'Flipkart',
    'acolite': 'Accolite',
    'traveloca': 'Traveloka',
    'goladman': 'Goldman Sachs',
    'morgain': 'Morgan Stanley',
    'lenksart': 'Lenskart',

    // Names whose accepted spelling title-casing would get wrong.
    'makemytrip': 'MakeMyTrip',
    'tcs': 'TCS',
    'ibm': 'IBM',
    'sap': 'SAP',
    'hsbc': 'HSBC',
    'vmware': 'VMware',
    'ebay': 'eBay',
    'paypal': 'PayPal',
    'payu': 'PayU',
    'linkedin': 'LinkedIn',
    'inmobi': 'InMobi',
    'sharechat': 'ShareChat',
    'bankbazaar': 'BankBazaar',
    'coupondunia': 'CouponDunia',
    'freecharge': 'FreeCharge',
    'greyorange': 'GreyOrange',
    'geekyants': 'GeekyAnts',
    'factset': 'FactSet',
    'media.net': 'Media.net',
    'housing.com': 'Housing.com',
    'yatra.com': 'Yatra.com',
    'epam': 'EPAM',
  };

  /// Tags that are not employers: leftover halves of names whose other half is
  /// ambiguous (`labs` sits on SAP, Infosys and Housing.com rows alike), generic
  /// words (`group`, `systems`, `technologies`), and content that never was a
  /// company (`interview`/`qs`, and one row of topic tags).
  static const Set<String> _notCompanies = {
    'interview', 'qs',
    'labs', 'iq', 'systems', 'india', 'solutions', 'group',
    'technologies', 'technology', 'inc', 'academy', 'networking',
    'club', 'direct', 'innovation',
    'arrays', 'dynamic', 'programming',
    // Single-occurrence fragments with no identifiable employer behind them.
    'payload', 'oats', 'wooker', 'josh', 'maccafe', 'triology',
    'epic', 'citicorp', 'monotype',
  };

  /// Splits a raw `companies` value into canonical employer names.
  ///
  /// Returns a Set, which is what makes the fragment merge work: a problem
  /// tagged `goldman,sachs` yields {Goldman Sachs} once, not twice.
  static Set<String> parse(String raw) {
    if (raw.isEmpty) return const {};
    // Some rows separate with a NON-BREAKING space rather than a comma.
    // Written as an escape: as a raw character it is invisible here and a
    // formatter or a copy-paste could silently turn it into the plain space
    // that legitimately sits inside "goldman sachs".
    final normalised = raw.replaceAll('\u00a0', ',');
    final names = <String>{};
    for (final part in normalised.split(',')) {
      // Stray leading/trailing "+" marks survived the import ("samsung+").
      final tag = part.trim().replaceAll(RegExp(r'^\++|\++$'), '').trim().toLowerCase();
      if (tag.isEmpty || _notCompanies.contains(tag)) continue;
      names.add(_canonical[tag] ?? _titleCase(tag));
    }
    return names;
  }

  static String _titleCase(String s) => s
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
