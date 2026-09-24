[
  {
    name: RewardCurrency::CASH_BACK_NAME,
    cents_per_point: 1.0,
    description: "Cash-back cards. One point is one cent, and the card's earning rates hold the " \
                 "percentage (4% back is stored as 4.0), so $100 at 4.0 earns 400 points = $4.00."
  },
  {
    name: "Membership Rewards",
    cents_per_point: 1.0,
    description: "American Express Membership Rewards. Valued at 1.0 cent: Amex Travel and statement " \
                 "credits redeem at 1 cent per point, and transfers to Aeroplan (1:1) can do better."
  },
  {
    name: "Aeroplan",
    cents_per_point: 1.5,
    description: "Air Canada Aeroplan. Valued at 1.5 cents: economy flight rewards typically return " \
                 "1.2 to 2.0 cents per point, so 1.5 is a conservative midpoint."
  },
  {
    name: "Avion",
    cents_per_point: 1.0,
    description: "RBC Avion. Valued at 1.0 cent: the Air Travel Redemption Schedule and Avion travel " \
                 "bookings return about 1 cent per point; statement credits are worth less (0.58)."
  },
  {
    name: "Scene+",
    cents_per_point: 1.0,
    description: "Scotiabank Scene+. Valued at 1.0 cent: 1,000 points redeem for $10 in travel, " \
                 "at Cineplex, or at Empire grocery stores."
  },
  {
    name: "BMO Rewards",
    cents_per_point: 0.7,
    description: "BMO Rewards. Valued at 0.7 cents: travel redemptions return 150 points per dollar " \
                 "(0.67 cents) and statement credits slightly less."
  },
  {
    name: "CIBC Aventura",
    cents_per_point: 1.0,
    description: "CIBC Aventura. Valued at 1.0 cent: the Aventura Airline Rewards Chart and CIBC " \
                 "Rewards Centre bookings return roughly 1 cent per point."
  },
  {
    name: "PC Optimum",
    cents_per_point: 0.1,
    description: "PC Optimum. Valued at 0.1 cents: 10,000 points redeem for $10 at Loblaw banners " \
                 "and Shoppers Drug Mart (1 point = $0.001)."
  },
  {
    name: "TD Rewards",
    cents_per_point: 0.5,
    description: "TD Rewards. Valued at 0.5 cents: travel booked through Expedia For TD redeems at " \
                 "200 points per dollar; other redemptions are worth less."
  },
  {
    name: "Air Miles",
    cents_per_point: 10.5,
    description: "Air Miles (Cash rewards). Valued at 10.5 cents per mile: 95 Cash Miles redeem for " \
                 "$10 at participating partners. Earn rates are miles per dollar (1 mile per $12 = 0.0833)."
  },
  {
    name: "Marriott Bonvoy",
    cents_per_point: 0.7,
    description: "Marriott Bonvoy. Valued at 0.7 cents: typical hotel award redemptions return " \
                 "0.6 to 0.9 cents per point."
  },
  {
    name: "WestJet Dollars",
    cents_per_point: 1.0,
    description: "WestJet dollars are worth $1 CAD each toward WestJet flights and vacations. Earning " \
                 "rates are stored as a percentage (2% back = 2.0), so one point here is one cent of " \
                 "WestJet dollars."
  },
  {
    name: "A la carte Rewards",
    cents_per_point: 0.8,
    description: "National Bank a la carte Rewards. Valued at 0.8 cents: travel through the a la carte " \
                 "site returns about 1 cent per point, statement credits about 0.83."
  },
  {
    name: "MBNA Rewards",
    cents_per_point: 1.0,
    description: "MBNA Rewards. Valued at 1.0 cent: travel and merchandise redeem at 1 cent per point; " \
                 "cash back redemptions are worth about half that."
  },
  {
    name: "Triangle Rewards",
    cents_per_point: 1.0,
    description: "Canadian Tire Money collected through Triangle Rewards. One point is one cent of " \
                 "Canadian Tire Money, spendable at Canadian Tire, Sport Chek, Mark's and partners, " \
                 "so percentage rates are stored directly (3% = 3.0)."
  },
  {
    name: "BonusDollars",
    cents_per_point: 1.0,
    description: "Desjardins BonusDollars are worth $1 each toward travel, merchandise, or a " \
                 "statement credit; rates are stored as a percentage (4% = 4.0), one point per cent."
  },
  {
    name: "Brim Rewards",
    cents_per_point: 1.0,
    description: "Brim points are worth 1 cent each toward any purchase on the card."
  },
  {
    name: "Walmart Reward Dollars",
    cents_per_point: 1.0,
    description: "Walmart Reward Dollars are worth $1 each at Walmart and Walmart.ca; rates are " \
                 "stored as a percentage (1.25% = 1.25), one point per cent."
  }
].each { |currency| Seeds::UpsertRewardCurrency.call(**currency) }
