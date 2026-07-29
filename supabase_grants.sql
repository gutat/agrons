-- Grant anon role access to all tables
GRANT USAGE ON SCHEMA public TO anon;
GRANT SELECT ON products TO anon;
GRANT SELECT ON gallery_items TO anon;
GRANT SELECT ON company_info TO anon;
GRANT INSERT ON contact_submissions TO anon;
