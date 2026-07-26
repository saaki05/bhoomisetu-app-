insert into categories (name, slug, icon_name, display_order) values
  ('Cereals', 'cereals', 'grass', 1),
  ('Vegetables', 'vegetables', 'eco', 2),
  ('Fruits', 'fruits', 'nutrition', 3),
  ('Pulses', 'pulses', 'spa', 4),
  ('Oilseeds', 'oilseeds', 'opacity', 5),
  ('Spices', 'spices', 'local_fire_department', 6),
  ('Cash Crops', 'cash-crops', 'payments', 7),
  ('Flowers', 'flowers', 'local_florist', 8),
  ('Dairy', 'dairy', 'icecream', 9),
  ('Other', 'other', 'more_horiz', 99)
on conflict (slug) do nothing;
