# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

if Rails.env.development?
  user = User.find_or_initialize_by(email: "test@mail.com")
  if user.new_record? || user.invited?
    user.password = "password123"
    user.password_confirmation = "password123"
    user.name = "Test User"
    user.save!
    Cellars::ProvisionDefaultCellar.call(user: user) unless user.cellar_memberships.exists?(role: :owner)
    puts "Seeded test user: test@mail.com / password123"
  else
    puts "Test user already exists: test@mail.com"
  end

# db/seeds.rb
# Seeds for Cellr — wines, wineries, regions, cellar entries
# Does NOT create users — run after creating users via registration
#
# Usage:
#   rails db:seed
#
# Safe to re-run — uses find_or_create_by throughout

puts "🍷 Seeding Cellr..."

# ─────────────────────────────────────────
# REGIONS
# ─────────────────────────────────────────

regions_data = [
  "Napa Valley",
  "Sonoma Coast",
  "Willamette Valley",
  "Santa Barbara County",
  "Paso Robles",
  "Santa Cruz Mountains",
  "Bordeaux",
  "Burgundy",
  "Champagne",
  "Rhône Valley",
  "Alsace",
  "Loire Valley",
  "Barossa Valley",
  "McLaren Vale",
  "Tuscany",
  "Piedmont",
  "Veneto",
  "Rioja",
  "Ribera del Duero",
  "Priorat",
  "Mosel",
  "Rheingau",
  "Marlborough",
  "Central Otago",
  "Mendoza"
]

regions = regions_data.each_with_object({}) do |name, hash|
  region = Region.find_or_create_by!(normalized_name: name.downcase.strip) do |r|
    r.name = name
  end
  hash[name] = region
  print "."
end

puts "\n✅ #{regions.count} regions seeded"

# ─────────────────────────────────────────
# WINERIES
# ─────────────────────────────────────────

wineries_data = [
  "Opus One Winery",
  "Kistler Vineyards",
  "Ridge Vineyards",
  "Domaine de la Romanée-Conti",
  "Château Margaux",
  "Château Pétrus",
  "Screaming Eagle",
  "Harlan Estate",
  "Sine Qua Non",
  "Cayuse Vineyards",
  "Billecart-Salmon",
  "Pol Roger",
  "Krug",
  "Louis Roederer",
  "Château d'Esclans",
  "Domaine Leflaive",
  "Domaine Leroy",
  "Guigal",
  "Chapoutier",
  "Antinori",
  "Sassicaia",
  "Gaja",
  "Allegrini",
  "Vega Sicilia",
  "Alvaro Palacios",
  "Egon Müller",
  "Joh. Jos. Prüm",
  "Cloudy Bay",
  "Felton Road",
  "Catena Zapata",
  "Williams Selyem",
  "Paul Hobbs",
  "Shafer Vineyards",
  "Duckhorn Vineyards",
  "Jordan Winery"
]

wineries = wineries_data.each_with_object({}) do |name, hash|
  winery = Winery.find_or_create_by!(normalized_name: name.downcase.strip) do |w|
    w.name = name
  end
  hash[name] = winery
  print "."
end

puts "\n✅ #{wineries.count} wineries seeded"

# ─────────────────────────────────────────
# WINES
# ─────────────────────────────────────────

wines_data = [
  { winery: "Opus One Winery",             name: "Opus One",                     wine_type: "red",       varietal: "Cabernet Sauvignon", region: "Napa Valley" },
  { winery: "Screaming Eagle",             name: "Cabernet Sauvignon",           wine_type: "red",       varietal: "Cabernet Sauvignon", region: "Napa Valley" },
  { winery: "Harlan Estate",               name: "The Maiden",                   wine_type: "red",       varietal: "Cabernet Sauvignon", region: "Napa Valley" },
  { winery: "Shafer Vineyards",            name: "Hillside Select",              wine_type: "red",       varietal: "Cabernet Sauvignon", region: "Napa Valley" },
  { winery: "Duckhorn Vineyards",          name: "Three Palms Merlot",           wine_type: "red",       varietal: "Merlot",             region: "Napa Valley" },
  { winery: "Jordan Winery",               name: "Cabernet Sauvignon",           wine_type: "red",       varietal: "Cabernet Sauvignon", region: "Napa Valley" },
  { winery: "Paul Hobbs",                  name: "Beckstoffer To Kalon",         wine_type: "red",       varietal: "Cabernet Sauvignon", region: "Napa Valley" },
  { winery: "Kistler Vineyards",           name: "Kistler Vineyard",             wine_type: "white",     varietal: "Chardonnay",         region: "Sonoma Coast" },
  { winery: "Kistler Vineyards",           name: "Les Noisetiers",               wine_type: "white",     varietal: "Chardonnay",         region: "Sonoma Coast" },
  { winery: "Williams Selyem",             name: "Rochioli Riverblock",          wine_type: "red",       varietal: "Pinot Noir",         region: "Sonoma Coast" },
  { winery: "Ridge Vineyards",             name: "Monte Bello",                  wine_type: "red",       varietal: "Cabernet Blend",     region: "Santa Cruz Mountains" },
  { winery: "Ridge Vineyards",             name: "Lytton Springs",               wine_type: "red",       varietal: "Zinfandel",          region: "Sonoma Coast" },
  { winery: "Sine Qua Non",                name: "The Hussy",                    wine_type: "white",     varietal: "Roussanne",          region: "Santa Barbara County" },
  { winery: "Cayuse Vineyards",            name: "En Chamberlin",                wine_type: "red",       varietal: "Syrah",              region: "Willamette Valley" },
  { winery: "Billecart-Salmon",            name: "Blanc de Blancs",              wine_type: "sparkling", varietal: "Chardonnay",         region: "Champagne" },
  { winery: "Billecart-Salmon",            name: "Rosé",                         wine_type: "rosé",      varietal: "Pinot Noir",         region: "Champagne" },
  { winery: "Pol Roger",                   name: "Cuvée Sir Winston Churchill",  wine_type: "sparkling", varietal: "Chardonnay",         region: "Champagne" },
  { winery: "Krug",                        name: "Grande Cuvée",                 wine_type: "sparkling", varietal: "Chardonnay",         region: "Champagne" },
  { winery: "Louis Roederer",              name: "Cristal",                      wine_type: "sparkling", varietal: "Chardonnay",         region: "Champagne" },
  { winery: "Château Margaux",             name: "Château Margaux",              wine_type: "red",       varietal: "Cabernet Sauvignon", region: "Bordeaux" },
  { winery: "Château Pétrus",              name: "Pétrus",                       wine_type: "red",       varietal: "Merlot",             region: "Bordeaux" },
  { winery: "Domaine Leflaive",            name: "Puligny-Montrachet",           wine_type: "white",     varietal: "Chardonnay",         region: "Burgundy" },
  { winery: "Domaine Leroy",               name: "Chambolle-Musigny",            wine_type: "red",       varietal: "Pinot Noir",         region: "Burgundy" },
  { winery: "Domaine de la Romanée-Conti", name: "La Tâche",                    wine_type: "red",       varietal: "Pinot Noir",         region: "Burgundy" },
  { winery: "Guigal",                      name: "La Mouline",                   wine_type: "red",       varietal: "Syrah",              region: "Rhône Valley" },
  { winery: "Chapoutier",                  name: "L'Ermite",                     wine_type: "red",       varietal: "Syrah",              region: "Rhône Valley" },
  { winery: "Château d'Esclans",           name: "Whispering Angel",             wine_type: "rosé",      varietal: "Grenache",           region: "Rhône Valley" },
  { winery: "Château d'Esclans",           name: "Rock Angel",                   wine_type: "rosé",      varietal: "Grenache",           region: "Rhône Valley" },
  { winery: "Antinori",                    name: "Tignanello",                   wine_type: "red",       varietal: "Sangiovese",         region: "Tuscany" },
  { winery: "Sassicaia",                   name: "Sassicaia",                    wine_type: "red",       varietal: "Cabernet Sauvignon", region: "Tuscany" },
  { winery: "Gaja",                        name: "Barbaresco",                   wine_type: "red",       varietal: "Nebbiolo",           region: "Piedmont" },
  { winery: "Allegrini",                   name: "Amarone della Valpolicella",   wine_type: "red",       varietal: "Corvina",            region: "Veneto" },
  { winery: "Vega Sicilia",                name: "Único",                        wine_type: "red",       varietal: "Tempranillo",        region: "Ribera del Duero" },
  { winery: "Alvaro Palacios",             name: "L'Ermita",                     wine_type: "red",       varietal: "Grenache",           region: "Priorat" },
  { winery: "Egon Müller",                 name: "Scharzhofberger Riesling TBA", wine_type: "dessert",   varietal: "Riesling",           region: "Mosel" },
  { winery: "Joh. Jos. Prüm",              name: "Wehlener Sonnenuhr Auslese",   wine_type: "white",     varietal: "Riesling",           region: "Mosel" },
  { winery: "Cloudy Bay",                  name: "Sauvignon Blanc",              wine_type: "white",     varietal: "Sauvignon Blanc",    region: "Marlborough" },
  { winery: "Felton Road",                 name: "Bannockburn Pinot Noir",       wine_type: "red",       varietal: "Pinot Noir",         region: "Central Otago" },
  { winery: "Catena Zapata",               name: "Adrianna Vineyard",            wine_type: "red",       varietal: "Malbec",             region: "Mendoza" }
]

wines = wines_data.each_with_object({}) do |data, hash|
  winery = wineries[data[:winery]]
  region = regions[data[:region]]

  next puts("\n⚠️  Missing winery: #{data[:winery]}") unless winery
  next puts("\n⚠️  Missing region: #{data[:region]}") unless region

  wine = Wine.find_or_create_by!(
    winery_id: winery.id,
    name:      data[:name],
    varietal:  data[:varietal],
    wine_type: data[:wine_type]
  ) do |w|
    w.region_id = region.id
  end

  hash[data[:name]] = wine
  print "."
end

puts "\n✅ #{wines.count} wines seeded"

# ─────────────────────────────────────────
# CELLAR ENTRIES
# Only runs if users exist
# ─────────────────────────────────────────

users = User.all.to_a

if users.empty?
  puts "⚠️  No users found — skipping cellar entries. Register first then re-run."
else
  puts "👤 Found #{users.count} user(s) — seeding cellar entries..."

  entry_templates = [
    { wine: "Opus One",                   vintage: 2019, price_cents: 22500 },
    { wine: "Opus One",                   vintage: 2018, price_cents: 21000 },
    { wine: "Kistler Vineyard",           vintage: 2021, price_cents: 8500  },
    { wine: "Monte Bello",                vintage: 2018, price_cents: 17500 },
    { wine: "Blanc de Blancs",            vintage: nil,  price_cents: 11000 },
    { wine: "Whispering Angel",           vintage: 2023, price_cents: 2800  },
    { wine: "Cristal",                    vintage: 2015, price_cents: 32000 },
    { wine: "Tignanello",                 vintage: 2020, price_cents: 9500  },
    { wine: "Hillside Select",            vintage: 2017, price_cents: 35000 },
    { wine: "Barbaresco",                 vintage: 2019, price_cents: 18000 },
    { wine: "Wehlener Sonnenuhr Auslese", vintage: 2018, price_cents: 7500  },
    { wine: "Sauvignon Blanc",            vintage: 2023, price_cents: 2200  },
    { wine: "Lytton Springs",             vintage: 2020, price_cents: 4500  },
    { wine: "Rochioli Riverblock",        vintage: 2021, price_cents: 12000 },
    { wine: "Único",                      vintage: 2010, price_cents: 45000 }
  ]

  users.each do |user|
    cellar = user.cellars.first
    next puts("⚠️  User #{user.email} has no cellar — skipping") unless cellar

    entry_templates.sample(rand(6..10)).each do |t|
      wine = wines[t[:wine]]
      next puts("\n⚠️  Wine not found: #{t[:wine]}") unless wine
      next if CellarEntry.exists?(cellar: cellar, wine: wine, vintage: t[:vintage])

      CellarEntry.create!(
        cellar:               cellar,
        wine:                 wine,
        vintage:              t[:vintage],
        purchase_price_cents: t[:price_cents]
      )
      print "."
    end
  end

  puts "\n✅ Cellar entries seeded"
end

puts "\n🍾 Done! Cellr is ready."

end
