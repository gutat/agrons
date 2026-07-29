-- Add placeholder images to existing products
UPDATE products SET
  thumbnail = 'https://picsum.photos/seed/' || slug || '-thumb/400/300',
  images = ARRAY['https://picsum.photos/seed/' || slug || '-1/800/600', 'https://picsum.photos/seed/' || slug || '-2/800/600']
WHERE thumbnail IS NULL;

-- Insert gallery items with placeholder images
INSERT INTO gallery_items (category, title, description, image, thumbnail, alt, sort_order) VALUES
('production', 'Cocopeat Production Line', 'Automated washing and buffering process', 'https://picsum.photos/seed/prod-1/1200/800', 'https://picsum.photos/seed/prod-1-thumb/400/300', 'Cocopeat production line', 1),
('production', 'Quality Control Lab', 'Rigorous quality testing at every stage', 'https://picsum.photos/seed/prod-2/1200/800', 'https://picsum.photos/seed/prod-2-thumb/400/300', 'Quality control laboratory', 2),
('factory', 'Factory Overview', 'State-of-the-art processing facility', 'https://picsum.photos/seed/factory-1/1200/800', 'https://picsum.photos/seed/factory-1-thumb/400/300', 'Factory facility', 3),
('factory', 'Packaging Area', 'Automated packaging and labeling', 'https://picsum.photos/seed/factory-2/1200/800', 'https://picsum.photos/seed/factory-2-thumb/400/300', 'Packaging area', 4),
('certifications', 'RHP Certificate', 'RHP certification for European markets', 'https://picsum.photos/seed/cert-rhp/1200/800', 'https://picsum.photos/seed/cert-rhp-thumb/400/300', 'RHP certificate', 5),
('certifications', 'OMRI Listed', 'Organic Materials Review Institute listing', 'https://picsum.photos/seed/cert-omri/1200/800', 'https://picsum.photos/seed/cert-omri-thumb/400/300', 'OMRI listing', 6),
('team', 'Management Team', 'Our experienced leadership team', 'https://picsum.photos/seed/team-1/1200/800', 'https://picsum.photos/seed/team-1-thumb/400/300', 'Management team', 7),
('team', 'Production Staff', 'Dedicated workers ensuring quality output', 'https://picsum.photos/seed/team-2/1200/800', 'https://picsum.photos/seed/team-2-thumb/400/300', 'Production staff', 8);
