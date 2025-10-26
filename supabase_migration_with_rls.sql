-- ==========================================
-- INTERVAL V2 DATABASE SCHEMA
-- ==========================================

-- Drop existing tables if they exist
DROP TABLE IF EXISTS articles CASCADE;
DROP TABLE IF EXISTS trending_topics CASCADE;
DROP TABLE IF EXISTS news_outlets CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Drop existing functions
DROP FUNCTION IF EXISTS calculate_coverage_percentage CASCADE;
DROP FUNCTION IF EXISTS set_trial_end_date CASCADE;

-- ==========================================
-- CORE TABLES
-- ==========================================

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    auth_provider TEXT NOT NULL, -- 'apple' or 'google'
    auth_provider_id TEXT NOT NULL,
    subscription_tier TEXT NOT NULL DEFAULT 'free', -- 'free', 'premium'
    subscription_status TEXT NOT NULL DEFAULT 'trial', -- 'trial', 'active', 'expired', 'canceled'
    trial_end_date TIMESTAMPTZ,
    subscription_start_date TIMESTAMPTZ,
    subscription_end_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- News Outlets table
CREATE TABLE news_outlets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    logo_url TEXT,
    website_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Trending Topics table
CREATE TABLE trending_topics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    display_order INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Articles table
CREATE TABLE articles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    subtitle TEXT NOT NULL,
    summary_cards JSONB NOT NULL DEFAULT '[]'::jsonb,
    deep_dive TEXT NOT NULL,
    evidence_cards JSONB NOT NULL DEFAULT '[]'::jsonb,
    carousel_media JSONB NOT NULL DEFAULT '[]'::jsonb,
    coverage_outlet_ids UUID[] NOT NULL DEFAULT '{}',
    total_outlets INT NOT NULL DEFAULT 0,
    coverage_percentage INT NOT NULL DEFAULT 0,
    coverage_status TEXT NOT NULL DEFAULT 'unknown',
    is_featured BOOLEAN NOT NULL DEFAULT false,
    priority INT NOT NULL DEFAULT 0,
    trending_topic_ids UUID[] NOT NULL DEFAULT '{}',
    published_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==========================================
-- TRIGGER FUNCTIONS
-- ==========================================

-- Function to calculate coverage percentage
CREATE OR REPLACE FUNCTION calculate_coverage_percentage()
RETURNS TRIGGER AS $$
DECLARE
    outlet_count INT;
    coverage_count INT;
    percentage INT;
    status TEXT;
BEGIN
    -- Get total active outlets
    SELECT COUNT(*) INTO outlet_count FROM news_outlets WHERE is_active = true;
    
    -- Set total outlets
    NEW.total_outlets := outlet_count;
    
    -- Count how many outlets covered this article
    coverage_count := array_length(NEW.coverage_outlet_ids, 1);
    IF coverage_count IS NULL THEN
        coverage_count := 0;
    END IF;
    
    -- Calculate percentage
    IF outlet_count > 0 THEN
        percentage := ROUND((coverage_count::DECIMAL / outlet_count) * 100);
    ELSE
        percentage := 0;
    END IF;
    
    NEW.coverage_percentage := percentage;
    
    -- Determine coverage status
    IF percentage = 0 THEN
        status := 'suppressed';
    ELSIF percentage < 50 THEN
        status := 'medium';
    ELSE
        status := 'well_covered';
    END IF;
    
    NEW.coverage_status := status;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to set trial end date (7 days from creation)
CREATE OR REPLACE FUNCTION set_trial_end_date()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.subscription_status = 'trial' AND NEW.trial_end_date IS NULL THEN
        NEW.trial_end_date := NOW() + INTERVAL '7 days';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- TRIGGERS
-- ==========================================

-- Trigger for calculating coverage on article insert/update
CREATE TRIGGER calculate_article_coverage
    BEFORE INSERT OR UPDATE ON articles
    FOR EACH ROW
    EXECUTE FUNCTION calculate_coverage_percentage();

-- Trigger for setting trial end date on user creation
CREATE TRIGGER set_user_trial_end
    BEFORE INSERT ON users
    FOR EACH ROW
    EXECUTE FUNCTION set_trial_end_date();

-- ==========================================
-- ROW LEVEL SECURITY (RLS)
-- ==========================================

-- IMPORTANT: For testing, we'll disable RLS on public-facing tables
-- In production, you should enable RLS and add proper policies

ALTER TABLE articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE trending_topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE news_outlets ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Allow anonymous read access for testing
CREATE POLICY "Allow anonymous read on articles" ON articles
    FOR SELECT USING (true);

CREATE POLICY "Allow anonymous read on trending_topics" ON trending_topics
    FOR SELECT USING (true);

CREATE POLICY "Allow anonymous read on news_outlets" ON news_outlets
    FOR SELECT USING (true);

-- Users can only read their own data
CREATE POLICY "Users can read own data" ON users
    FOR SELECT USING (auth.uid() = id);

-- ==========================================
-- SAMPLE DATA (Optional - for testing)
-- ==========================================

-- Insert sample news outlets
INSERT INTO news_outlets (name, website_url, is_active) VALUES
('CNN', 'https://cnn.com', true),
('Fox News', 'https://foxnews.com', true),
('BBC', 'https://bbc.com', true),
('Reuters', 'https://reuters.com', true),
('The New York Times', 'https://nytimes.com', true),
('The Guardian', 'https://theguardian.com', true),
('Al Jazeera', 'https://aljazeera.com', true),
('NPR', 'https://npr.org', true);

-- Insert sample trending topics
INSERT INTO trending_topics (name, display_order, is_active) VALUES
('Politics', 1, true),
('Technology', 2, true),
('Climate', 3, true),
('Economy', 4, true),
('Health', 5, true),
('Sports', 6, true);

-- Insert a sample article
INSERT INTO articles (
    title,
    subtitle,
    summary_cards,
    deep_dive,
    evidence_cards,
    carousel_media,
    coverage_outlet_ids,
    is_featured,
    priority,
    trending_topic_ids,
    published_at
) VALUES (
    'Major Climate Summit Concludes with Historic Agreement',
    'World leaders commit to ambitious carbon reduction targets by 2030',
    '[
        {
            "id": "550e8400-e29b-41d4-a716-446655440001",
            "emoji": "🌍",
            "title": "Global Commitment",
            "body": "195 countries signed the landmark agreement, representing over 98% of global emissions."
        },
        {
            "id": "550e8400-e29b-41d4-a716-446655440002",
            "emoji": "📉",
            "title": "Emission Targets",
            "body": "Signatories pledged to reduce carbon emissions by 45% from 2020 levels by 2030."
        },
        {
            "id": "550e8400-e29b-41d4-a716-446655440003",
            "emoji": "💰",
            "title": "Financial Support",
            "body": "Developed nations committed $100 billion annually to help developing countries transition to clean energy."
        }
    ]'::jsonb,
    'The two-week climate summit in Geneva brought together world leaders, scientists, and environmental activists in what many are calling the most significant international climate agreement since the Paris Accord. After intense negotiations that extended into the early morning hours of the final day, delegates reached a consensus on binding emission reduction targets and financial mechanisms to support the transition to renewable energy.

The agreement includes several groundbreaking provisions: mandatory annual reporting of emissions data, financial penalties for countries that fail to meet their targets, and the establishment of an international clean energy technology fund. Developing nations secured guarantees for technology transfer and capacity building support.

Scientists have cautiously welcomed the agreement, noting that while the targets are ambitious, they represent the minimum action needed to limit global warming to 1.5 degrees Celsius above pre-industrial levels. However, critics point out that the agreement lacks enforcement mechanisms and relies heavily on voluntary compliance.',
    '[
        {
            "id": "660e8400-e29b-41d4-a716-446655440001",
            "icon": "newspaper",
            "headline": "UN Secretary-General Calls It \"Historic Moment\"",
            "body": "The UN chief praised the agreement as a turning point in the fight against climate change, emphasizing the unprecedented level of international cooperation.",
            "source_url": "https://example.com/un-statement"
        },
        {
            "id": "660e8400-e29b-41d4-a716-446655440002",
            "icon": "chart.line.uptrend.xyaxis",
            "headline": "Climate Scientists Project 1.8°C Warming by 2050",
            "body": "New modeling suggests that if all pledges are met, global temperature rise could be limited to 1.8°C, narrowly avoiding the worst climate scenarios.",
            "source_url": "https://example.com/climate-model"
        }
    ]'::jsonb,
    '[
        {
            "id": "770e8400-e29b-41d4-a716-446655440001",
            "type": "image",
            "url": "https://picsum.photos/800/600?random=1"
        },
        {
            "id": "770e8400-e29b-41d4-a716-446655440002",
            "type": "image",
            "url": "https://picsum.photos/800/600?random=2"
        }
    ]'::jsonb,
    ARRAY(SELECT id FROM news_outlets WHERE name IN ('CNN', 'BBC', 'Reuters', 'The Guardian', 'NPR'))::UUID[],
    true,
    100,
    ARRAY(SELECT id FROM trending_topics WHERE name IN ('Politics', 'Climate'))::UUID[],
    NOW() - INTERVAL '2 hours'
);

-- Insert another sample article
INSERT INTO articles (
    title,
    subtitle,
    summary_cards,
    deep_dive,
    evidence_cards,
    carousel_media,
    coverage_outlet_ids,
    is_featured,
    priority,
    trending_topic_ids,
    published_at
) VALUES (
    'Tech Giants Announce AI Safety Initiative',
    'Leading companies pledge to develop artificial intelligence responsibly',
    '[
        {
            "id": "550e8400-e29b-41d4-a716-446655440010",
            "emoji": "🤖",
            "title": "Industry Coalition",
            "body": "Major tech companies including Google, Microsoft, and OpenAI have formed a consortium to establish AI safety standards."
        },
        {
            "id": "550e8400-e29b-41d4-a716-446655440011",
            "emoji": "🛡️",
            "title": "Safety Protocols",
            "body": "The initiative includes mandatory safety testing, transparency requirements, and independent audits for advanced AI systems."
        }
    ]'::jsonb,
    'In an unprecedented show of cooperation, the world''s leading AI companies have announced a joint initiative to address growing concerns about artificial intelligence safety. The consortium will establish industry-wide standards for testing, deployment, and monitoring of advanced AI systems. This comes amid increasing pressure from governments and civil society groups calling for regulation of rapidly advancing AI technology.',
    '[
        {
            "id": "660e8400-e29b-41d4-a716-446655440010",
            "icon": "person.3",
            "headline": "Tech CEOs Meet with Government Officials",
            "body": "Leaders from major AI companies held closed-door meetings with regulators to discuss the framework for responsible AI development.",
            "source_url": "https://example.com/tech-meeting"
        }
    ]'::jsonb,
    '[
        {
            "id": "770e8400-e29b-41d4-a716-446655440010",
            "type": "image",
            "url": "https://picsum.photos/800/600?random=3"
        }
    ]'::jsonb,
    ARRAY(SELECT id FROM news_outlets WHERE name IN ('CNN', 'The New York Times', 'BBC'))::UUID[],
    false,
    90,
    ARRAY(SELECT id FROM trending_topics WHERE name = 'Technology')::UUID[],
    NOW() - INTERVAL '5 hours'
);

-- ==========================================
-- INDEXES FOR PERFORMANCE
-- ==========================================

CREATE INDEX idx_articles_is_featured ON articles(is_featured);
CREATE INDEX idx_articles_priority ON articles(priority);
CREATE INDEX idx_articles_published_at ON articles(published_at);
CREATE INDEX idx_articles_trending_topics ON articles USING GIN(trending_topic_ids);
CREATE INDEX idx_trending_topics_display_order ON trending_topics(display_order);
CREATE INDEX idx_trending_topics_is_active ON trending_topics(is_active);
