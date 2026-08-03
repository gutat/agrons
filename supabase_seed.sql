-- ============================================
-- Mazrea Bumi Nusantara - Supabase Tables
-- Run this in Supabase SQL Editor
-- Based on content from mazreanusantara.com
-- ============================================

-- ============================================
-- FULL SETUP
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
  video_url TEXT,
  media JSONB DEFAULT '[]',
  specifications JSONB DEFAULT '[]',
  applications TEXT[] DEFAULT '{}',
  packaging JSONB DEFAULT '{}',
  moq TEXT,
  lead_time TEXT,
  origin TEXT DEFAULT 'Indonesia',
  sort_order INT DEFAULT 0,
  published BOOLEAN DEFAULT true,
  translations JSONB DEFAULT '{}',
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
  type TEXT DEFAULT 'image' CHECK (type IN ('image', 'video')),
  sort_order INT DEFAULT 0,
  published BOOLEAN DEFAULT true,
  translations JSONB DEFAULT '{}',
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

-- 2b. GALLERY SECTION (single row -- section title/description)
CREATE TABLE gallery_section (
  id INT PRIMARY KEY DEFAULT 1,
  title TEXT DEFAULT 'Our Facilities',
  description TEXT,
  published BOOLEAN DEFAULT true,
  translations JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT single_row CHECK (id = 1)
);
ALTER TABLE gallery_section ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can view gallery section" ON gallery_section
  FOR SELECT TO anon, authenticated
  USING (published = true);
CREATE POLICY "Admin can manage gallery section" ON gallery_section
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

-- 3. HOME SECTION (single row)
CREATE TABLE home_section (
  id INT PRIMARY KEY DEFAULT 1,
  company_name TEXT NOT NULL,
  tagline TEXT,
  description TEXT,
  subtitle TEXT,
  hero_video_url TEXT,
  hero_image_url TEXT,
  published BOOLEAN DEFAULT true,
  translations JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT single_row CHECK (id = 1)
);
ALTER TABLE home_section ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can view home section" ON home_section
  FOR SELECT TO anon, authenticated
  USING (published = true);
CREATE POLICY "Admin can manage home section" ON home_section
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

-- 4. ABOUT SECTION (single row)
CREATE TABLE about_section (
  id INT PRIMARY KEY DEFAULT 1,
  title TEXT DEFAULT 'Our Company',
  mission TEXT,
  vision TEXT,
  values JSONB DEFAULT '[]',
  hero_video_url TEXT,
  hero_image_url TEXT,
  published BOOLEAN DEFAULT true,
  translations JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT single_row CHECK (id = 1)
);
ALTER TABLE about_section ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can view about section" ON about_section
  FOR SELECT TO anon, authenticated
  USING (published = true);
CREATE POLICY "Admin can manage about section" ON about_section
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

-- 5. COMPANY INFO (single row -- contact & social only)
CREATE TABLE company_info (
  id INT PRIMARY KEY DEFAULT 1,
  name TEXT,
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

-- 6. CONTACT SUBMISSIONS
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
-- ROLE GRANTS (required by Supabase API)
-- ============================================
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
GRANT INSERT ON contact_submissions TO anon;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- ============================================
-- AUTO-UPDATE updated_at TRIGGER
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_gallery_section_updated_at
  BEFORE UPDATE ON gallery_section
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_home_section_updated_at
  BEFORE UPDATE ON home_section
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_about_section_updated_at
  BEFORE UPDATE ON about_section
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_company_info_updated_at
  BEFORE UPDATE ON company_info
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- INSERT SEED DATA (from mazreanusantara.com)
-- ============================================

-- Home Section
INSERT INTO home_section (id, company_name, tagline, description, subtitle, hero_image_url, translations)
VALUES (
  1,
  'PT Agro Nusa Sejahtera',
  'The Largest Coconut Derivatives Producers in Indonesia',
  'As a trusted supplier of premium coconut derivatives, we deliver consistent quality, sustainable sourcing, and scalable production for global buyers. Our product range includes cocopeat, coco fiber, coconut shell charcoal, desiccated coconut, and more -- crafted to meet international standards.',
  'Premium coconut derivatives: cocopeat, cocofiber, coconut charcoal, desiccated coconut, and more -- crafted to meet international standards.',
  'https://picsum.photos/seed/home-hero/1600/900',
  '{"tagline": {"id": "Produsen Turunan Kelapa Terbesar di Indonesia"}, "description": {"id": "Sebagai pemasok tepercaya turunan kelapa premium, kami menghadirkan kualitas konsisten, sumber daya berkelanjutan, dan produksi berskala besar untuk pembeli global. Jajaran produk kami mencakup cocopeat, serat kelapa, arang tempurung kelapa, kelapa parut kering, dan lainnya -- dibuat sesuai standar internasional."}, "subtitle": {"id": "Turunan kelapa premium: cocopeat, serat kelapa, arang kelapa, kelapa parut kering, dan lainnya -- dibuat sesuai standar internasional."}}'
);

-- About Section
INSERT INTO about_section (id, title, mission, vision, values, hero_image_url, translations)
VALUES (
  1,
  'About PT Agro Nusa Sejahtera',
  'To provide sustainable, high-quality coconut-derived products for global agriculture, industry, and household needs through responsible sourcing and innovative processing.',
  'To be the world''s most trusted and innovative coconut derivatives supplier, driving sustainability from coconut farms to global markets.',
  '[{"icon": "leaf", "title": {"en": "Sustainability", "id": "Keberlanjutan"}, "description": {"en": "Zero-waste coconut processing from husk to finished product", "id": "Pengolahan kelapa tanpa limbah dari sabut hingga produk jadi"}}, {"icon": "shield", "title": {"en": "Quality", "id": "Kualitas"}, "description": {"en": "International standard quality control across all product lines", "id": "Kontrol kualitas standar internasional di semua lini produk"}}, {"icon": "users", "title": {"en": "Partnership", "id": "Kemitraan"}, "description": {"en": "Long-term relationships with growers and global buyers", "id": "Hubungan jangka panjang dengan petani dan pembeli global"}}, {"icon": "globe", "title": {"en": "Global Reach", "id": "Jangkauan Global"}, "description": {"en": "Exporting coconut derivatives to worldwide markets", "id": "Mengekspor turunan kelapa ke pasar dunia"}}, {"icon": "clock", "title": {"en": "Experience", "id": "Pengalaman"}, "description": {"en": "4+ years of expertise in coconut derivative industry", "id": "4+ tahun keahlian di industri turunan kelapa"}}]',
  'https://picsum.photos/seed/about-hero/1600/900',
  '{"title": {"id": "Tentang PT Agro Nusa Sejahtera"}, "mission": {"id": "Menyediakan produk turunan kelapa yang berkelanjutan dan berkualitas tinggi untuk kebutuhan pertanian, industri, dan rumah tangga global melalui sumber daya yang bertanggung jawab dan pengolahan inovatif."}, "vision": {"id": "Menjadi pemasok turunan kelapa paling tepercaya dan inovatif di dunia, mendorong keberlanjutan dari perkebunan kelapa hingga pasar global."}}'
);

-- Company Info
INSERT INTO company_info (id, name, logo_url, contact, social)
VALUES (
  1,
  'PT Agro Nusa Sejahtera',
  'https://picsum.photos/seed/logo/200/200',
  '{"address": "Pekanbaru, Indonesia", "phone": "+62", "email": "export@agronusa.co.id", "whatsapp": "+62"}',
  '{}'
);

-- Default video URL for products
-- Replace with actual R2 URLs when available
-- Video: https://pub-<hash>.r2.dev/products/{slug}-demo.mp4

-- Products: Cocopeat
INSERT INTO products (name, category, slug, short_description, thumbnail, video_url, media, specifications, applications, sort_order, translations) VALUES
('Cocopeat Block 5kg', 'cocopeat', 'cocopeat-block-5kg', 'Premium compressed cocopeat block for professional horticulture and agriculture',
 'https://picsum.photos/seed/cocopeat-block-5kg/400/300',
 NULL,
 '[{"type": "image", "url": "https://picsum.photos/seed/cocopeat-block-5kg-1/800/600"}, {"type": "image", "url": "https://picsum.photos/seed/cocopeat-block-5kg-2/800/600"}]',
 '[{"name": {"en": "Weight", "id": "Berat"}, "value": {"en": "5 kg", "id": "5 kg"}}, {"name": {"en": "Expansion", "id": "Pengembangan"}, "value": {"en": "15-18 L/kg", "id": "15-18 L/kg"}}, {"name": {"en": "EC", "id": "EC"}, "value": {"en": "< 0.5", "id": "< 0.5"}, "unit": "mS/cm"}, {"name": {"en": "pH", "id": "pH"}, "value": {"en": "5.5 - 6.5", "id": "5.5 - 6.5"}}, {"name": {"en": "Moisture", "id": "Kelembaban"}, "value": {"en": "< 15", "id": "< 15"}, "unit": "%"}, {"name": {"en": "Organic Matter", "id": "Bahan Organik"}, "value": {"en": "> 95", "id": "> 95"}, "unit": "%"}]',
 '["Professional horticulture", "Greenhouse growing", "Soil amendment", "Seed starting"]', 1,
 '{"name": {"id": "Blok Cocopeat 5kg"}, "short_description": {"id": "Blok cocopeat padat premium untuk hortikultura dan pertanian profesional"}}'),
('Cocopeat Briquette 650g', 'cocopeat', 'cocopeat-briquette-650g', 'Compact cocopeat briquette ideal for home gardening and retail',
 'https://picsum.photos/seed/cocopeat-briquette-650g/400/300',
 NULL,
 '[{"type": "image", "url": "https://picsum.photos/seed/cocopeat-briquette-650g/800/600"}]',
 '[{"name": {"en": "Weight", "id": "Berat"}, "value": {"en": "650g", "id": "650g"}}, {"name": {"en": "Expansion", "id": "Pengembangan"}, "value": {"en": "8-10 L", "id": "8-10 L"}}, {"name": {"en": "EC", "id": "EC"}, "value": {"en": "< 0.5", "id": "< 0.5"}, "unit": "mS/cm"}, {"name": {"en": "pH", "id": "pH"}, "value": {"en": "5.5 - 6.5", "id": "5.5 - 6.5"}}]',
 '["Home gardening", "Retail consumer", "Seed starting", "Potting mix"]', 2,
 '{"name": {"id": "Briket Cocopeat 650g"}, "short_description": {"id": "Briket cocopeat ringkas ideal untuk berkebun rumahan dan ritel"}}'),
('Cocopeat Grow Bag 100L', 'cocopeat', 'cocopeat-growbag-100l', 'Ready-to-use cocopeat grow bag for commercial greenhouse production',
 'https://picsum.photos/seed/cocopeat-growbag-100l/400/300',
 NULL,
 '[{"type": "image", "url": "https://picsum.photos/seed/cocopeat-growbag-100l-1/800/600"}, {"type": "video", "url": "https://flow-content.google/video/bf26c7ce-46c6-4a42-9d05-413b98eb1422?Expires=1785400442&KeyName=labs-flow-prod-cdn-key&Signature=Pk0jc9ZASnp2-FlaylWOuy_RqLY"}]',
 '[{"name": {"en": "Volume", "id": "Volume"}, "value": {"en": "100 L", "id": "100 L"}}, {"name": {"en": "EC", "id": "EC"}, "value": {"en": "< 0.8", "id": "< 0.8"}, "unit": "mS/cm"}, {"name": {"en": "pH", "id": "pH"}, "value": {"en": "5.5 - 6.5", "id": "5.5 - 6.5"}}, {"name": {"en": "Pre-buffered", "id": "Pra-buffer"}, "value": {"en": "Yes", "id": "Ya"}}]',
 '["Greenhouse tomatoes", "Cucumber", "Pepper", "Strawberry cultivation"]', 3,
 '{"name": {"id": "Kantong Tanam Cocopeat 100L"}, "short_description": {"id": "Kantong tanam cocopeat siap pakai untuk produksi rumah kaca komersial"}}');

-- Products: Cocofiber
INSERT INTO products (name, category, slug, short_description, thumbnail, video_url, media, specifications, applications, sort_order, translations) VALUES
('Cocofiber Bale 100kg', 'cocofiber', 'cocofiber-bale-100kg', 'Premium natural coconut fiber for industrial and horticultural applications',
 'https://picsum.photos/seed/cocofiber-bale-100kg/400/300',
 NULL,
 '[{"type": "image", "url": "https://picsum.photos/seed/cocofiber-bale-100kg-1/800/600"}, {"type": "video", "url": "https://flow-content.google/video/bf26c7ce-46c6-4a42-9d05-413b98eb1422?Expires=1785400442&KeyName=labs-flow-prod-cdn-key&Signature=Pk0jc9ZASnp2-FlaylWOuy_RqLY"}]',
 '[{"name": {"en": "Fiber Length", "id": "Panjang Serat"}, "value": {"en": "15-25 cm", "id": "15-25 cm"}}, {"name": {"en": "Moisture", "id": "Kelembaban"}, "value": {"en": "12-15", "id": "12-15"}, "unit": "%"}, {"name": {"en": "Impurities", "id": "Kotoran"}, "value": {"en": "< 2", "id": "< 2"}, "unit": "%"}, {"name": {"en": "Color", "id": "Warna"}, "value": {"en": "Golden Brown", "id": "Coklat Keemasan"}}]',
 '["Mattress filling", "Upholstery", "Erosion control mats", "Geotextiles"]', 4,
 '{"name": {"id": "Bal Cocofiber 100kg"}, "short_description": {"id": "Serat kelapa alami premium untuk aplikasi industri dan hortikultura"}}'),
('Cocofiber Rope 16mm', 'cocofiber', 'cocofiber-rope-16mm', 'Natural biodegradable cocofiber rope for landscaping and decoration',
 'https://picsum.photos/seed/cocofiber-rope-16mm/400/300',
 NULL,
 '[{"type": "image", "url": "https://picsum.photos/seed/cocofiber-rope-16mm/800/600"}]',
 '[{"name": {"en": "Diameter", "id": "Diameter"}, "value": {"en": "16mm", "id": "16mm"}}, {"name": {"en": "Material", "id": "Bahan"}, "value": {"en": "100% Natural Cocofiber", "id": "100% Cocofiber Alami"}}, {"name": {"en": "Biodegradable", "id": "Terurai Alami"}, "value": {"en": "Yes", "id": "Ya"}}, {"name": {"en": "Tensile Strength", "id": "Kekuatan Tarik"}, "value": {"en": "High", "id": "Tinggi"}}]',
 '["Gardening", "Landscaping", "Decoration", "Erosion control"]', 5,
 '{"name": {"id": "Tali Cocofiber 16mm"}, "short_description": {"id": "Tali cocofiber alami yang dapat terurai untuk lanskap dan dekorasi"}}'),
('Cocofiber Erosion Control Mat 2m x 50m', 'cocofiber', 'cocofiber-mat-2m', 'Biodegradable erosion control blanket for slope protection and revegetation',
 'https://picsum.photos/seed/cocofiber-mat-2m/400/300',
 NULL,
 '[{"type": "image", "url": "https://picsum.photos/seed/cocofiber-mat-2m/800/600"}]',
 '[{"name": {"en": "Width", "id": "Lebar"}, "value": {"en": "2m", "id": "2m"}}, {"name": {"en": "Length", "id": "Panjang"}, "value": {"en": "50m", "id": "50m"}}, {"name": {"en": "Material", "id": "Bahan"}, "value": {"en": "100% Natural Cocofiber", "id": "100% Cocofiber Alami"}}, {"name": {"en": "Biodegradable", "id": "Terurai Alami"}, "value": {"en": "100%", "id": "100%"}}]',
 '["Slope protection", "Revegetation", "Landscaping", "Mining reclamation"]', 6,
 '{"name": {"id": "Tikar Pengendali Erosi Cocofiber 2m x 50m"}, "short_description": {"id": "Selimut pengendali erosi yang dapat terurai untuk perlindungan lereng dan revegetasi"}}');

-- Gallery Section
INSERT INTO gallery_section (id, title, description, translations)
VALUES (
  1,
  'Our Facilities',
  'A look inside our production, quality control, and team.',
  '{"title": {"id": "Fasilitas Kami"}, "description": {"id": "Melihat langsung proses produksi, kontrol kualitas, dan tim kami."}}'
);

-- Gallery Items (using picsum.photos placeholder images)
INSERT INTO gallery_items (category, title, description, image, thumbnail, type, sort_order, translations) VALUES
('production', 'Cocopeat Block Production', 'Premium compressed cocopeat blocks ready for export', 'https://picsum.photos/seed/gallery-production-1/1200/800', 'https://picsum.photos/seed/gallery-production-1-thumb/400/300', 'image', 1, '{"title": {"id": "Produksi Blok Cocopeat"}, "description": {"id": "Blok cocopeat padat premium siap ekspor"}}'),
('production', 'Cocofiber Processing Line', 'Natural coconut fiber processing and grading', 'https://picsum.photos/seed/gallery-production-2/1200/800', 'https://picsum.photos/seed/gallery-production-2-thumb/400/300', 'image', 2, '{"title": {"id": "Lini Pengolahan Cocofiber"}, "description": {"id": "Pengolahan dan sortasi serat kelapa alami"}}'),
('factory', 'Our Facility', 'Production facility in Pekanbaru, Riau', 'https://picsum.photos/seed/gallery-facility/1200/800', 'https://picsum.photos/seed/gallery-facility-thumb/400/300', 'image', 3, '{"title": {"id": "Fasilitas Kami"}, "description": {"id": "Fasilitas produksi di Pekanbaru, Riau"}}'),
('factory', 'Warehouse & Storage', 'Climate-controlled storage for coconut derivatives', 'https://picsum.photos/seed/gallery-warehouse/1200/800', 'https://picsum.photos/seed/gallery-warehouse-thumb/400/300', 'image', 4, '{"title": {"id": "Gudang & Penyimpanan"}, "description": {"id": "Penyimpanan turunan kelapa dengan pengatur suhu"}}'),
('certifications', 'Export Documentation', 'Export documentation and international trade compliance', 'https://picsum.photos/seed/gallery-cert/1200/800', 'https://picsum.photos/seed/gallery-cert-thumb/400/300', 'image', 5, '{"title": {"id": "Dokumentasi Ekspor"}, "description": {"id": "Dokumentasi ekspor dan kepatuhan perdagangan internasional"}}'),
('production', 'Packaging & Quality Control', 'Best packaging practices to maintain product quality and cleanliness', 'https://picsum.photos/seed/gallery-packing/1200/800', 'https://picsum.photos/seed/gallery-packing-thumb/400/300', 'image', 6, '{"title": {"id": "Pengemasan & Kontrol Kualitas"}, "description": {"id": "Praktik pengemasan terbaik untuk menjaga kualitas dan kebersihan produk"}}'),
('production', 'Coconut Raw Materials', 'Selected mature coconuts for premium derivative production', 'https://picsum.photos/seed/gallery-raw/1200/800', 'https://picsum.photos/seed/gallery-raw-thumb/400/300', 'image', 7, '{"title": {"id": "Bahan Baku Kelapa"}, "description": {"id": "Kelapa matang terpilih untuk produksi turunan premium"}}'),
('factory', 'Export Shipment', 'Container loading for international shipment', 'https://picsum.photos/seed/gallery-export/1200/800', 'https://picsum.photos/seed/gallery-export-thumb/400/300', 'image', 8, '{"title": {"id": "Pengiriman Ekspor"}, "description": {"id": "Pemuatan kontainer untuk pengiriman internasional"}}');
