-- SQL script to create the feed_urls table in Supabase Postgres

-- Create the feed_urls table
CREATE TABLE IF NOT EXISTS feed_urls (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create an index on the url column for faster lookups
CREATE INDEX IF NOT EXISTS idx_feed_urls_url ON feed_urls(url);

-- Create an index on user_id for faster user-specific queries
CREATE INDEX IF NOT EXISTS idx_feed_urls_user_id ON feed_urls(user_id);

-- Create a composite unique index to prevent duplicate URLs per user
CREATE UNIQUE INDEX IF NOT EXISTS idx_feed_urls_user_url ON feed_urls(user_id, url);

-- Create a trigger to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_feed_urls_updated_at 
    BEFORE UPDATE ON feed_urls 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE feed_urls ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow read access to all users" ON feed_urls;
DROP POLICY IF EXISTS "Allow insert for authenticated users" ON feed_urls;
DROP POLICY IF EXISTS "Allow update for authenticated users" ON feed_urls;
DROP POLICY IF EXISTS "Allow delete for authenticated users" ON feed_urls;

-- Create policies that restrict access to user's own data
-- Allow users to read only their own feed URLs
CREATE POLICY "Users can read their own feed URLs" 
    ON feed_urls FOR SELECT 
    USING (auth.uid() = user_id);

-- Allow users to insert their own feed URLs
CREATE POLICY "Users can insert their own feed URLs" 
    ON feed_urls FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Allow users to update only their own feed URLs
CREATE POLICY "Users can update their own feed URLs" 
    ON feed_urls FOR UPDATE 
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Allow users to delete only their own feed URLs
CREATE POLICY "Users can delete their own feed URLs" 
    ON feed_urls FOR DELETE 
    USING (auth.uid() = user_id);
