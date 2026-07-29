-- ============================================
-- PT Agro Nusa Sejahtera - Supabase Tables
-- Run this in Supabase SQL Editor
-- ============================================

-- 1. PRODUCTS
CREATE TABLE products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('cocopeat', 'cocofiber')),
  slug TEXT UNIQUE NOT NULL,
  short_description TEXT,
  description TEXT,
  images TEXT[],
  thumbnail TEXT,
  specifications JSONB DEFAULT '[]',
  applications TEXT[] DEFAULT '{}',
  packaging JSONB DEFAULT '{}',
  moq TEXT,
  lead_time TEXT,
  origin TEXT DEFAULT 'Indonesia',
  sort_order INT DEFAULT 0,
  published BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can view published products" ON products
  FOR SELECT TO anon, authenticated
  USING (published = true);
CREATE POLICY "Admin can manage products" ON products
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

-- 2. GALLERY ITEMS
CREATE TABLE gallery_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  category TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  image TEXT NOT NULL,
  thumbnail TEXT,
  alt TEXT,
  sort_order INT DEFAULT 0,
  published BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE gallery_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can view published gallery" ON gallery_items
  FOR SELECT TO anon, authenticated
  USING (published = true);
CREATE POLICY "Admin can manage gallery" ON gallery_items
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

-- 3. COMPANY INFO (single row)
CREATE TABLE company_info (
  id INT PRIMARY KEY DEFAULT 1,
  name TEXT NOT NULL,
  tagline TEXT,
  mission TEXT,
  vision TEXT,
  values JSONB DEFAULT '[]',
  description TEXT,
  logo_url TEXT,
  contact JSONB DEFAULT '{}',
  social JSONB DEFAULT '{}',
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT single_row CHECK (id = 1)
);
ALTER TABLE company_info ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can view company info" ON company_info
  FOR SELECT TO anon, authenticated
  USING (true);
CREATE POLICY "Admin can update company info" ON company_info
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

-- 4. CONTACT SUBMISSIONS
CREATE TABLE contact_submissions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  company TEXT,
  phone TEXT,
  country TEXT,
  message TEXT NOT NULL,
  inquiry_type TEXT CHECK (inquiry_type IN ('general', 'quote', 'sample', 'partnership', 'technical')),
  product_interest TEXT[],
  source TEXT DEFAULT 'website',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  read BOOLEAN DEFAULT FALSE
);
ALTER TABLE contact_submissions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can submit contact form"
  ON contact_submissions FOR INSERT TO anon, authenticated
  WITH CHECK (true);
CREATE POLICY "Only admin can view submissions"
  ON contact_submissions FOR SELECT TO authenticated
  USING (true);

-- ============================================
-- INSERT SAMPLE DATA
-- ============================================

-- Company Info
INSERT INTO company_info (id, name, tagline, mission, vision, values, contact)
VALUES (
  1,
  'PT Agro Nusa Sejahtera',
  'Premium Cocopeat & Cocofiber from Indonesia',
  'To provide sustainable, high-quality growing media for global agriculture.',
  'To be the world''s most trusted supplier of coconut-based growing media.',
  '[{"icon": "leaf", "title": "Sustainability", "description": "Zero-waste coconut processing"}, {"icon": "shield", "title": "Quality", "description": "RHP, OMRI, ISO certified"}, {"icon": "users", "title": "Partnership", "description": "Long-term relationships with growers"}, {"icon": "globe", "title": "Global Reach", "description": "Exporting to 20+ countries"}]',
  '{"address": "Medan Industrial Estate, Indonesia", "phone": "+62 61 1234 5678", "email": "export@agronusa.co.id", "whatsapp": "+6281234567890"}'
);

-- Products (Cocopeat)
INSERT INTO products (name, category, slug, short_description, specifications, applications, sort_order) VALUES
('Cocopeat Block 5kg', 'cocopeat', 'cocopeat-block-5kg', 'Premium compressed cocopeat block for professional horticulture', '[{"name": "EC", "value": "< 0.5", "unit": "mS/cm"}, {"name": "pH", "value": "5.5 - 6.5"}, {"name": "Expansion", "value": "15-18 L/kg"}]', '{"Seed starting", "Hydroponics", "Soil amendment"}', 1),
('Cocopeat Briquette 650g', 'cocopeat', 'cocopeat-briquette-650g', 'Compact briquette for home gardening & retail', '[{"name": "Weight", "value": "650g"}, {"name": "Expansion", "value": "8-10 L"}, {"name": "EC", "value": "< 0.5"}]', '{"Home gardening", "Retail", "Seed starting"}', 2),
('Cocopeat Grow Bag 100L', 'cocopeat', 'cocopeat-growbag-100l', 'Ready-to-use grow bag for commercial greenhouses', '[{"name": "Volume", "value": "100 L"}, {"name": "EC", "value": "< 0.8"}, {"name": "pH", "value": "5.5 - 6.5"}]', '{"Greenhouse production", "Tomato", "Cucumber", "Pepper"}', 3);

-- Products (Cocofiber)
INSERT INTO products (name, category, slug, short_description, specifications, applications, sort_order) VALUES
('Cocofiber Bale 250kg', 'cocofiber', 'cocofiber-bale-250kg', 'Premium coconut fiber bale for mattress & upholstery industry', '[{"name": "Fiber Length", "value": "20-30 cm"}, {"name": "Moisture", "value": "12-15%"}, {"name": "Impurities", "value": "< 2%"}]', '{"Mattress filling", "Upholstery", "Rope production"}', 4),
('Cocofiber Rope 20mm', 'cocofiber', 'cocofiber-rope-20mm', 'Natural fiber rope for erosion control & geotextiles', '[{"name": "Diameter", "value": "20mm"}, {"name": "Tensile Strength", "value": "High"}, {"name": "Biodegradable", "value": "Yes"}]', '{"Erosion control", "Geotextiles", "Decoration"}', 5),
('Cocofiber Erosion Control Mat 2m', 'cocofiber', 'cocofiber-mat-2m', 'Biodegradable erosion control blanket for slopes', '[{"name": "Width", "value": "2m"}, {"name": "Length", "value": "50m"}, {"name": "Biodegradable", "value": "100%"}]', '{"Slope protection", "Landscaping", "Erosion control"}', 6);
