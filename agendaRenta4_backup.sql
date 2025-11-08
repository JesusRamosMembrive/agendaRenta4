--
-- PostgreSQL database dump
--

\restrict ybEYh36Zynfx7wG6y4zHdp3aNEsepXUGgiL0IYUMfwjsYpeQdMleid57CQrkiyY

-- Dumped from database version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: jesusramos
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO jesusramos;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: jesusramos
--

COMMENT ON SCHEMA public IS '';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alert_settings; Type: TABLE; Schema: public; Owner: jesusramos
--

CREATE TABLE public.alert_settings (
    id integer NOT NULL,
    task_type_id integer NOT NULL,
    alert_frequency text NOT NULL,
    enabled boolean DEFAULT true,
    alert_day text
);


ALTER TABLE public.alert_settings OWNER TO jesusramos;

--
-- Name: alert_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: jesusramos
--

CREATE SEQUENCE public.alert_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.alert_settings_id_seq OWNER TO jesusramos;

--
-- Name: alert_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jesusramos
--

ALTER SEQUENCE public.alert_settings_id_seq OWNED BY public.alert_settings.id;


--
-- Name: crawl_runs; Type: TABLE; Schema: public; Owner: jesusramos
--

CREATE TABLE public.crawl_runs (
    id integer NOT NULL,
    started_at timestamp without time zone DEFAULT now(),
    finished_at timestamp without time zone,
    status text DEFAULT 'running'::text,
    root_url text NOT NULL,
    max_depth integer DEFAULT 5,
    max_urls integer,
    urls_discovered integer DEFAULT 0,
    urls_broken integer DEFAULT 0,
    urls_timeout integer DEFAULT 0,
    errors text,
    created_by text,
    CONSTRAINT crawl_runs_status_check CHECK ((status = ANY (ARRAY['running'::text, 'completed'::text, 'failed'::text, 'cancelled'::text])))
);


ALTER TABLE public.crawl_runs OWNER TO jesusramos;

--
-- Name: crawl_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: jesusramos
--

CREATE SEQUENCE public.crawl_runs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.crawl_runs_id_seq OWNER TO jesusramos;

--
-- Name: crawl_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jesusramos
--

ALTER SEQUENCE public.crawl_runs_id_seq OWNED BY public.crawl_runs.id;


--
-- Name: custom_dictionary; Type: TABLE; Schema: public; Owner: jesusramos
--

CREATE TABLE public.custom_dictionary (
    id integer NOT NULL,
    word character varying(100) NOT NULL,
    word_lower character varying(100) NOT NULL,
    category character varying(50) DEFAULT 'other'::character varying,
    frequency integer DEFAULT 0,
    approved_by integer,
    approved_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.custom_dictionary OWNER TO jesusramos;

--
-- Name: TABLE custom_dictionary; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON TABLE public.custom_dictionary IS 'User-approved custom dictionary words for Hunspell spell checker';


--
-- Name: COLUMN custom_dictionary.word; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.custom_dictionary.word IS 'Original word with capitalization preserved';


--
-- Name: COLUMN custom_dictionary.word_lower; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.custom_dictionary.word_lower IS 'Lowercase version for case-insensitive matching';


--
-- Name: COLUMN custom_dictionary.category; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.custom_dictionary.category IS 'Word category: technical, geographic, brand, financial, other';


--
-- Name: COLUMN custom_dictionary.frequency; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.custom_dictionary.frequency IS 'Number of times this word appeared as error (for ranking)';


--
-- Name: COLUMN custom_dictionary.approved_by; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.custom_dictionary.approved_by IS 'User who approved adding this word';


--
-- Name: COLUMN custom_dictionary.notes; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.custom_dictionary.notes IS 'Optional notes about why word was added';


--
-- Name: custom_dictionary_id_seq; Type: SEQUENCE; Schema: public; Owner: jesusramos
--

CREATE SEQUENCE public.custom_dictionary_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.custom_dictionary_id_seq OWNER TO jesusramos;

--
-- Name: custom_dictionary_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jesusramos
--

ALTER SEQUENCE public.custom_dictionary_id_seq OWNED BY public.custom_dictionary.id;


--
-- Name: discovered_urls; Type: TABLE; Schema: public; Owner: jesusramos
--

CREATE TABLE public.discovered_urls (
    id integer NOT NULL,
    url text NOT NULL,
    parent_url_id integer,
    depth integer DEFAULT 0 NOT NULL,
    discovered_at timestamp without time zone DEFAULT now(),
    last_checked timestamp without time zone,
    status_code integer,
    response_time double precision,
    is_broken boolean DEFAULT false,
    error_message text,
    active boolean DEFAULT true,
    crawl_run_id integer,
    is_priority boolean DEFAULT false
);


ALTER TABLE public.discovered_urls OWNER TO jesusramos;

--
-- Name: COLUMN discovered_urls.is_priority; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.discovered_urls.is_priority IS 'TRUE if this URL is from the original manually curated list (117 URLs from sections table)';


--
-- Name: discovered_urls_id_seq; Type: SEQUENCE; Schema: public; Owner: jesusramos
--

CREATE SEQUENCE public.discovered_urls_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.discovered_urls_id_seq OWNER TO jesusramos;

--
-- Name: discovered_urls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jesusramos
--

ALTER SEQUENCE public.discovered_urls_id_seq OWNED BY public.discovered_urls.id;


--
-- Name: health_snapshots; Type: TABLE; Schema: public; Owner: jesusramos
--

CREATE TABLE public.health_snapshots (
    id integer NOT NULL,
    snapshot_date timestamp without time zone DEFAULT now(),
    health_score double precision NOT NULL,
    total_urls integer NOT NULL,
    ok_urls integer NOT NULL,
    broken_urls integer NOT NULL,
    redirect_urls integer DEFAULT 0,
    error_urls integer DEFAULT 0
);


ALTER TABLE public.health_snapshots OWNER TO jesusramos;

--
-- Name: TABLE health_snapshots; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON TABLE public.health_snapshots IS 'Historical health metrics for URL validation tracking (Phase 2.4)';


--
-- Name: COLUMN health_snapshots.health_score; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.health_snapshots.health_score IS 'Percentage of healthy URLs (0-100)';


--
-- Name: COLUMN health_snapshots.total_urls; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.health_snapshots.total_urls IS 'Total number of URLs validated';


--
-- Name: COLUMN health_snapshots.ok_urls; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.health_snapshots.ok_urls IS 'Number of URLs with 2xx/3xx status';


--
-- Name: COLUMN health_snapshots.broken_urls; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.health_snapshots.broken_urls IS 'Number of URLs with 4xx/5xx status';


--
-- Name: health_snapshots_id_seq; Type: SEQUENCE; Schema: public; Owner: jesusramos
--

CREATE SEQUENCE public.health_snapshots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.health_snapshots_id_seq OWNER TO jesusramos;

--
-- Name: health_snapshots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jesusramos
--

ALTER SEQUENCE public.health_snapshots_id_seq OWNED BY public.health_snapshots.id;


--
-- Name: notification_preferences; Type: TABLE; Schema: public; Owner: jesusramos
--

CREATE TABLE public.notification_preferences (
    id integer NOT NULL,
    user_name text NOT NULL,
    email text NOT NULL,
    enable_email boolean DEFAULT true,
    enable_desktop boolean DEFAULT false,
    enable_in_app boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.notification_preferences OWNER TO jesusramos;

--
-- Name: notification_preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: jesusramos
--

CREATE SEQUENCE public.notification_preferences_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notification_preferences_id_seq OWNER TO jesusramos;

--
-- Name: notification_preferences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jesusramos
--

ALTER SEQUENCE public.notification_preferences_id_seq OWNED BY public.notification_preferences.id;


--
-- Name: pending_alerts; Type: TABLE; Schema: public; Owner: jesusramos
--

CREATE TABLE public.pending_alerts (
    id integer NOT NULL,
    task_type_id integer NOT NULL,
    due_date date NOT NULL,
    generated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    dismissed boolean DEFAULT false,
    dismissed_at timestamp without time zone
);


ALTER TABLE public.pending_alerts OWNER TO jesusramos;

--
-- Name: pending_alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: jesusramos
--

CREATE SEQUENCE public.pending_alerts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pending_alerts_id_seq OWNER TO jesusramos;

--
-- Name: pending_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jesusramos
--

ALTER SEQUENCE public.pending_alerts_id_seq OWNED BY public.pending_alerts.id;


--
-- Name: quality_check_batches; Type: TABLE; Schema: public; Owner: jesusramos
--

CREATE TABLE public.quality_check_batches (
    id integer NOT NULL,
    batch_type character varying(50) NOT NULL,
    status character varying(20) NOT NULL,
    total_urls integer DEFAULT 0 NOT NULL,
    processed_urls integer DEFAULT 0 NOT NULL,
    successful_checks integer DEFAULT 0 NOT NULL,
    failed_checks integer DEFAULT 0 NOT NULL,
    started_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    completed_at timestamp without time zone,
    created_by character varying(100),
    error_message text,
    CONSTRAINT batch_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'running'::character varying, 'completed'::character varying, 'failed'::character varying])::text[])))
);


ALTER TABLE public.quality_check_batches OWNER TO jesusramos;

--
-- Name: TABLE quality_check_batches; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON TABLE public.quality_check_batches IS 'Tracks batch quality check executions';


--
-- Name: COLUMN quality_check_batches.batch_type; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.quality_check_batches.batch_type IS 'Type of quality check being run';


--
-- Name: COLUMN quality_check_batches.status; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.quality_check_batches.status IS 'Current status of the batch: pending, running, completed, failed';


--
-- Name: COLUMN quality_check_batches.total_urls; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.quality_check_batches.total_urls IS 'Total number of URLs to process in this batch';


--
-- Name: COLUMN quality_check_batches.processed_urls; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.quality_check_batches.processed_urls IS 'Number of URLs processed so far';


--
-- Name: quality_check_batches_id_seq; Type: SEQUENCE; Schema: public; Owner: jesusramos
--

CREATE SEQUENCE public.quality_check_batches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.quality_check_batches_id_seq OWNER TO jesusramos;

--
-- Name: quality_check_batches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jesusramos
--

ALTER SEQUENCE public.quality_check_batches_id_seq OWNED BY public.quality_check_batches.id;


--
-- Name: quality_check_config; Type: TABLE; Schema: public; Owner: jesusramos
--

CREATE TABLE public.quality_check_config (
    id integer NOT NULL,
    user_id integer NOT NULL,
    check_type character varying(50) NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    run_after_crawl boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    scope text DEFAULT 'priority'::text,
    CONSTRAINT check_scope_values CHECK ((scope = ANY (ARRAY['all'::text, 'priority'::text]))),
    CONSTRAINT valid_check_type CHECK (((check_type)::text = ANY ((ARRAY['broken_links'::character varying, 'image_quality'::character varying, 'spell_check'::character varying, 'seo'::character varying, 'performance'::character varying, 'accessibility'::character varying])::text[])))
);


ALTER TABLE public.quality_check_config OWNER TO jesusramos;

--
-- Name: TABLE quality_check_config; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON TABLE public.quality_check_config IS 'User preferences for automated quality checks';


--
-- Name: COLUMN quality_check_config.check_type; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.quality_check_config.check_type IS 'Type of quality check: broken_links, image_quality, seo, performance, accessibility';


--
-- Name: COLUMN quality_check_config.enabled; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.quality_check_config.enabled IS 'Whether this check is enabled for the user';


--
-- Name: COLUMN quality_check_config.run_after_crawl; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.quality_check_config.run_after_crawl IS 'Whether to run this check automatically after crawl completion';


--
-- Name: COLUMN quality_check_config.scope; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.quality_check_config.scope IS 'Scope of URLs to check: "all" = all discovered URLs, "priority" = only is_priority=TRUE URLs';


--
-- Name: quality_check_config_id_seq; Type: SEQUENCE; Schema: public; Owner: jesusramos
--

CREATE SEQUENCE public.quality_check_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.quality_check_config_id_seq OWNER TO jesusramos;

--
-- Name: quality_check_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jesusramos
--

ALTER SEQUENCE public.quality_check_config_id_seq OWNED BY public.quality_check_config.id;


--
-- Name: quality_checks; Type: TABLE; Schema: public; Owner: jesusramos
--

CREATE TABLE public.quality_checks (
    id integer NOT NULL,
    section_id integer,
    check_type character varying(50) NOT NULL,
    status character varying(20) NOT NULL,
    score integer NOT NULL,
    message text NOT NULL,
    details jsonb,
    issues_found integer DEFAULT 0,
    execution_time_ms integer,
    checked_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    discovered_url_id integer,
    CONSTRAINT check_url_source CHECK (((section_id IS NOT NULL) OR (discovered_url_id IS NOT NULL))),
    CONSTRAINT quality_checks_score_check CHECK (((score >= 0) AND (score <= 100)))
);


ALTER TABLE public.quality_checks OWNER TO jesusramos;

--
-- Name: TABLE quality_checks; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON TABLE public.quality_checks IS 'Stores automated quality check results for monitored URLs';


--
-- Name: COLUMN quality_checks.check_type; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.quality_checks.check_type IS 'Type of quality check: image_quality, typo, broken_links, accessibility, seo, performance, security_headers, content_freshness';


--
-- Name: COLUMN quality_checks.status; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.quality_checks.status IS 'Overall check status: ok (score >= 80), warning (score >= 50), error (score < 50)';


--
-- Name: COLUMN quality_checks.score; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.quality_checks.score IS 'Numeric score 0-100 where 100 is perfect quality';


--
-- Name: COLUMN quality_checks.details; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.quality_checks.details IS 'JSON object with additional check-specific details (broken links list, image issues, etc.)';


--
-- Name: COLUMN quality_checks.issues_found; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.quality_checks.issues_found IS 'Number of issues detected during the check';


--
-- Name: COLUMN quality_checks.execution_time_ms; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.quality_checks.execution_time_ms IS 'Time taken to execute the check in milliseconds';


--
-- Name: COLUMN quality_checks.checked_at; Type: COMMENT; Schema: public; Owner: jesusramos
--

COMMENT ON COLUMN public.quality_checks.checked_at IS 'When the check was performed (may differ from created_at for batch imports)';


--
-- Name: quality_checks_id_seq; Type: SEQUENCE; Schema: public; Owner: jesusramos
--

CREATE SEQUENCE public.quality_checks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.quality_checks_id_seq OWNER TO jesusramos;

--
-- Name: quality_checks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jesusramos
--

ALTER SEQUENCE public.quality_checks_id_seq OWNED BY public.quality_checks.id;


--
-- Name: sections; Type: TABLE; Schema: public; Owner: jesusramos
--

CREATE TABLE public.sections (
    id integer NOT NULL,
    name text NOT NULL,
    url text NOT NULL,
    active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.sections OWNER TO jesusramos;

--
-- Name: sections_id_seq; Type: SEQUENCE; Schema: public; Owner: jesusramos
--

CREATE SEQUENCE public.sections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sections_id_seq OWNER TO jesusramos;

--
-- Name: sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jesusramos
--

ALTER SEQUENCE public.sections_id_seq OWNED BY public.sections.id;


--
-- Name: task_types; Type: TABLE; Schema: public; Owner: jesusramos
--

CREATE TABLE public.task_types (
    id integer NOT NULL,
    name text NOT NULL,
    display_name text NOT NULL,
    periodicity text NOT NULL,
    display_order integer DEFAULT 0
);


ALTER TABLE public.task_types OWNER TO jesusramos;

--
-- Name: task_types_id_seq; Type: SEQUENCE; Schema: public; Owner: jesusramos
--

CREATE SEQUENCE public.task_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_types_id_seq OWNER TO jesusramos;

--
-- Name: task_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jesusramos
--

ALTER SEQUENCE public.task_types_id_seq OWNED BY public.task_types.id;


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: jesusramos
--

CREATE TABLE public.tasks (
    id integer NOT NULL,
    section_id integer NOT NULL,
    task_type_id integer NOT NULL,
    period text NOT NULL,
    status text DEFAULT 'pending'::text,
    observations text,
    completed_date date,
    completed_by text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tasks OWNER TO jesusramos;

--
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: jesusramos
--

CREATE SEQUENCE public.tasks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tasks_id_seq OWNER TO jesusramos;

--
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jesusramos
--

ALTER SEQUENCE public.tasks_id_seq OWNED BY public.tasks.id;


--
-- Name: url_changes; Type: TABLE; Schema: public; Owner: jesusramos
--

CREATE TABLE public.url_changes (
    id integer NOT NULL,
    url_id integer,
    change_type text,
    old_value text,
    new_value text,
    detected_at timestamp without time zone DEFAULT now(),
    details text,
    CONSTRAINT url_changes_change_type_check CHECK ((change_type = ANY (ARRAY['new'::text, 'broken'::text, 'fixed'::text, 'removed'::text, 'status_change'::text])))
);


ALTER TABLE public.url_changes OWNER TO jesusramos;

--
-- Name: url_changes_id_seq; Type: SEQUENCE; Schema: public; Owner: jesusramos
--

CREATE SEQUENCE public.url_changes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.url_changes_id_seq OWNER TO jesusramos;

--
-- Name: url_changes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jesusramos
--

ALTER SEQUENCE public.url_changes_id_seq OWNED BY public.url_changes.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: jesusramos
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username text NOT NULL,
    password_hash text NOT NULL,
    full_name text NOT NULL,
    email text,
    active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO jesusramos;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: jesusramos
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO jesusramos;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jesusramos
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: alert_settings id; Type: DEFAULT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.alert_settings ALTER COLUMN id SET DEFAULT nextval('public.alert_settings_id_seq'::regclass);


--
-- Name: crawl_runs id; Type: DEFAULT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.crawl_runs ALTER COLUMN id SET DEFAULT nextval('public.crawl_runs_id_seq'::regclass);


--
-- Name: custom_dictionary id; Type: DEFAULT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.custom_dictionary ALTER COLUMN id SET DEFAULT nextval('public.custom_dictionary_id_seq'::regclass);


--
-- Name: discovered_urls id; Type: DEFAULT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.discovered_urls ALTER COLUMN id SET DEFAULT nextval('public.discovered_urls_id_seq'::regclass);


--
-- Name: health_snapshots id; Type: DEFAULT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.health_snapshots ALTER COLUMN id SET DEFAULT nextval('public.health_snapshots_id_seq'::regclass);


--
-- Name: notification_preferences id; Type: DEFAULT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.notification_preferences ALTER COLUMN id SET DEFAULT nextval('public.notification_preferences_id_seq'::regclass);


--
-- Name: pending_alerts id; Type: DEFAULT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.pending_alerts ALTER COLUMN id SET DEFAULT nextval('public.pending_alerts_id_seq'::regclass);


--
-- Name: quality_check_batches id; Type: DEFAULT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.quality_check_batches ALTER COLUMN id SET DEFAULT nextval('public.quality_check_batches_id_seq'::regclass);


--
-- Name: quality_check_config id; Type: DEFAULT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.quality_check_config ALTER COLUMN id SET DEFAULT nextval('public.quality_check_config_id_seq'::regclass);


--
-- Name: quality_checks id; Type: DEFAULT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.quality_checks ALTER COLUMN id SET DEFAULT nextval('public.quality_checks_id_seq'::regclass);


--
-- Name: sections id; Type: DEFAULT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.sections ALTER COLUMN id SET DEFAULT nextval('public.sections_id_seq'::regclass);


--
-- Name: task_types id; Type: DEFAULT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.task_types ALTER COLUMN id SET DEFAULT nextval('public.task_types_id_seq'::regclass);


--
-- Name: tasks id; Type: DEFAULT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.tasks ALTER COLUMN id SET DEFAULT nextval('public.tasks_id_seq'::regclass);


--
-- Name: url_changes id; Type: DEFAULT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.url_changes ALTER COLUMN id SET DEFAULT nextval('public.url_changes_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: alert_settings; Type: TABLE DATA; Schema: public; Owner: jesusramos
--

COPY public.alert_settings (id, task_type_id, alert_frequency, enabled, alert_day) FROM stdin;
9	1	daily	t	\N
10	2	weekly	t	monday
11	3	monthly	t	1
12	4	monthly	t	1
13	5	quarterly	t	1
14	6	monthly	t	1
15	7	monthly	t	1
16	8	quarterly	t	1
17	1	daily	t	\N
18	2	daily	t	\N
19	3	daily	t	\N
20	4	daily	t	\N
21	5	daily	t	\N
22	6	daily	t	\N
23	7	daily	t	\N
24	8	daily	t	\N
\.


--
-- Data for Name: crawl_runs; Type: TABLE DATA; Schema: public; Owner: jesusramos
--

COPY public.crawl_runs (id, started_at, finished_at, status, root_url, max_depth, max_urls, urls_discovered, urls_broken, urls_timeout, errors, created_by) FROM stdin;
1	2025-10-30 12:01:18.622507	2025-10-30 12:02:36.818984	completed	https://www.r4.com	3	50	50	0	0	\N	test-script
2	2025-10-30 12:19:00.670963	2025-10-30 13:14:22.227713	completed	https://www.r4.com	10	\N	2839	0	0	\N	full-crawl-comparison
3	2025-11-04 21:20:34.309489	\N	running	https://www.r4.com	10	\N	0	0	0	\N	Administrador
4	2025-11-05 07:41:33.692903	2025-11-05 08:54:28.510307	completed	https://www.r4.com	10	\N	2801	0	0	\N	Administrador
\.


--
-- Data for Name: custom_dictionary; Type: TABLE DATA; Schema: public; Owner: jesusramos
--

COPY public.custom_dictionary (id, word, word_lower, category, frequency, approved_by, approved_at, notes, created_at, updated_at) FROM stdin;
664	criptoactivos	criptoactivos	other	1	1	2025-11-05 18:12:09.982511	Añadida masivamente desde spell check	2025-11-05 18:12:09.982511	2025-11-05 18:12:09.982511
3	online	online	technical	50	\N	2025-11-05 17:22:49.309849	Common web term	2025-11-05 17:22:49.309849	2025-11-05 17:22:49.309849
4	app	app	technical	40	\N	2025-11-05 17:22:49.309849	Application abbreviation	2025-11-05 17:22:49.309849	2025-11-05 17:22:49.309849
5	email	email	technical	35	\N	2025-11-05 17:22:49.309849	Electronic mail	2025-11-05 17:22:49.309849	2025-11-05 17:22:49.309849
6	web	web	technical	30	\N	2025-11-05 17:22:49.309849	World Wide Web	2025-11-05 17:22:49.309849	2025-11-05 17:22:49.309849
7	link	link	technical	25	\N	2025-11-05 17:22:49.309849	Hyperlink	2025-11-05 17:22:49.309849	2025-11-05 17:22:49.309849
8	login	login	technical	20	\N	2025-11-05 17:22:49.309849	User authentication	2025-11-05 17:22:49.309849	2025-11-05 17:22:49.309849
9	software	software	technical	15	\N	2025-11-05 17:22:49.309849	Computer software	2025-11-05 17:22:49.309849	2025-11-05 17:22:49.309849
17	Renta4	renta4	brand	45	\N	2025-11-05 17:22:49.309849	Our company name	2025-11-05 17:22:49.309849	2025-11-05 17:22:49.309849
18	suscríbete	suscríbete	verb	25	\N	2025-11-05 17:22:49.309849	Imperative of suscribirse (subscribe)	2025-11-05 17:22:49.309849	2025-11-05 17:22:49.309849
19	contáctenos	contáctenos	verb	18	\N	2025-11-05 17:22:49.309849	Imperative of contactar (contact us)	2025-11-05 17:22:49.309849	2025-11-05 17:22:49.309849
20	regístrate	regístrate	verb	15	\N	2025-11-05 17:22:49.309849	Imperative of registrarse (register)	2025-11-05 17:22:49.309849	2025-11-05 17:22:49.309849
21	ETF	etf	financial	22	\N	2025-11-05 17:22:49.309849	Exchange-Traded Fund	2025-11-05 17:22:49.309849	2025-11-05 17:22:49.309849
22	ETFs	etfs	financial	20	\N	2025-11-05 17:22:49.309849	Exchange-Traded Funds (plural)	2025-11-05 17:22:49.309849	2025-11-05 17:22:49.309849
23	IBEX	ibex	financial	18	\N	2025-11-05 17:22:49.309849	Spanish stock market index	2025-11-05 17:22:49.309849	2025-11-05 17:22:49.309849
24	trading	trading	financial	16	\N	2025-11-05 17:22:49.309849	Financial trading	2025-11-05 17:22:49.309849	2025-11-05 17:22:49.309849
15	BlackRock	blackrock	other	18	\N	2025-11-05 17:22:49.309849	Añadida masivamente desde spell check	2025-11-05 17:22:49.309849	2025-11-05 18:12:16.920479
46	Healthscience	healthscience	other	4	1	2025-11-05 17:55:22.627273	Añadida masivamente desde spell check	2025-11-05 17:55:22.627273	2025-11-05 18:12:17.005278
49	European	european	other	2	1	2025-11-05 17:55:28.049208	Añadida masivamente desde spell check	2025-11-05 17:55:28.049208	2025-11-05 18:12:17.146528
50	Dividend	dividend	other	2	1	2025-11-05 17:55:30.130973	Añadida masivamente desde spell check	2025-11-05 17:55:30.130973	2025-11-05 18:12:17.190085
52	FTGF	ftgf	other	2	1	2025-11-05 17:55:33.85638	Añadida masivamente desde spell check	2025-11-05 17:55:33.85638	2025-11-05 18:12:17.278906
705	Caps	caps	other	1	1	2025-11-05 18:12:18.429878	Añadida masivamente desde spell check	2025-11-05 18:12:18.429878	2025-11-05 18:12:18.429878
34	monotitular	monotitular	other	5	1	2025-11-05 17:55:00.390792	Añadida masivamente desde spell check	2025-11-05 17:55:00.390792	2025-11-05 18:12:25.705556
35	multitular	multitular	other	5	1	2025-11-05 17:55:03.275381	Añadida masivamente desde spell check	2025-11-05 17:55:03.275381	2025-11-05 18:12:25.766161
36	SICAV	sicav	other	5	1	2025-11-05 17:55:04.79478	Añadida masivamente desde spell check	2025-11-05 17:55:04.79478	2025-11-05 18:12:25.831813
37	Select	select	other	5	1	2025-11-05 17:55:06.512207	Añadida masivamente desde spell check	2025-11-05 17:55:06.512207	2025-11-05 18:12:25.881927
38	Equity	equity	other	5	1	2025-11-05 17:55:07.308144	Añadida masivamente desde spell check	2025-11-05 17:55:07.308144	2025-11-05 18:12:25.926624
39	Amundi	amundi	other	8	1	2025-11-05 17:55:08.931719	Añadida masivamente desde spell check	2025-11-05 17:55:08.931719	2025-11-05 18:12:25.971998
41	Emerging	emerging	other	6	1	2025-11-05 17:55:12.801222	Añadida masivamente desde spell check	2025-11-05 17:55:12.801222	2025-11-05 18:12:26.080072
42	Markets	markets	other	6	1	2025-11-05 17:55:15.08624	Añadida masivamente desde spell check	2025-11-05 17:55:15.08624	2025-11-05 18:12:26.136276
43	Focus	focus	other	5	1	2025-11-05 17:55:16.603218	Añadida masivamente desde spell check	2025-11-05 17:55:16.603218	2025-11-05 18:12:26.190141
45	World	world	other	6	1	2025-11-05 17:55:20.655333	Añadida masivamente desde spell check	2025-11-05 17:55:20.655333	2025-11-05 18:12:26.234457
289	Guinness	guinness	other	4	1	2025-11-05 18:11:30.149579	Añadida masivamente desde spell check	2025-11-05 18:11:30.149579	2025-11-05 18:12:26.742896
183	NEUBERGER	neuberger	other	5	1	2025-11-05 18:11:25.211906	Añadida masivamente desde spell check	2025-11-05 18:11:25.211906	2025-11-05 18:12:27.279322
2	captcha	captcha	other	106	\N	2025-11-05 17:22:49.309849	Añadida masivamente desde spell check	2025-11-05 17:22:49.309849	2025-11-05 18:12:27.789975
760	Repsol	repsol	other	1	1	2025-11-05 18:33:31.140879	Añadida masivamente desde spell check	2025-11-05 18:33:31.140879	2025-11-05 18:33:31.140879
12	Madrid	madrid	other	12	\N	2025-11-05 17:22:49.309849	Añadida masivamente desde spell check	2025-11-05 17:22:49.309849	2025-11-05 18:11:45.550278
26	ABANTE	abante	other	4	1	2025-11-05 17:54:24.927768	Añadida masivamente desde spell check	2025-11-05 17:54:24.927768	2025-11-05 18:11:53.194865
27	DAVIS	davis	other	3	1	2025-11-05 17:54:27.221429	Añadida masivamente desde spell check	2025-11-05 17:54:27.221429	2025-11-05 18:11:53.259036
28	HALLEY	halley	other	3	1	2025-11-05 17:54:29.977703	Añadida masivamente desde spell check	2025-11-05 17:54:29.977703	2025-11-05 18:11:53.332027
29	SICAB	sicab	other	3	1	2025-11-05 17:54:32.183457	Añadida masivamente desde spell check	2025-11-05 17:54:32.183457	2025-11-05 18:11:53.391741
30	RAIFFEISEN	raiffeisen	other	3	1	2025-11-05 17:54:35.04163	Añadida masivamente desde spell check	2025-11-05 17:54:35.04163	2025-11-05 18:11:53.435254
31	ABERDEEN	aberdeen	other	3	1	2025-11-05 17:54:37.678386	Añadida masivamente desde spell check	2025-11-05 17:54:37.678386	2025-11-05 18:11:53.481675
32	DEGROOF	degroof	other	3	1	2025-11-05 17:54:40.531515	Añadida masivamente desde spell check	2025-11-05 17:54:40.531515	2025-11-05 18:11:53.527477
61	HENDERSON	henderson	other	2	1	2025-11-05 18:11:19.357655	Añadida masivamente desde spell check	2025-11-05 18:11:19.357655	2025-11-05 18:11:53.578773
62	INVESTORS	investors	other	2	1	2025-11-05 18:11:19.399644	Añadida masivamente desde spell check	2025-11-05 18:11:19.399644	2025-11-05 18:11:53.632808
63	ACATIS	acatis	other	2	1	2025-11-05 18:11:19.441784	Añadida masivamente desde spell check	2025-11-05 18:11:19.441784	2025-11-05 18:11:53.68858
64	DEKA	deka	other	2	1	2025-11-05 18:11:19.485762	Añadida masivamente desde spell check	2025-11-05 18:11:19.485762	2025-11-05 18:11:53.748477
65	HEPTAGON	heptagon	other	2	1	2025-11-05 18:11:19.534464	Añadida masivamente desde spell check	2025-11-05 18:11:19.534464	2025-11-05 18:11:53.805816
66	RENAISSANCE	renaissance	other	2	1	2025-11-05 18:11:19.581816	Añadida masivamente desde spell check	2025-11-05 18:11:19.581816	2025-11-05 18:11:53.851769
67	ADEPA	adepa	other	2	1	2025-11-05 18:11:19.627956	Añadida masivamente desde spell check	2025-11-05 18:11:19.627956	2025-11-05 18:11:53.896807
68	BANK	bank	other	2	1	2025-11-05 18:11:19.672125	Añadida masivamente desde spell check	2025-11-05 18:11:19.672125	2025-11-05 18:11:53.944438
69	HERMES	hermes	other	2	1	2025-11-05 18:11:19.714883	Añadida masivamente desde spell check	2025-11-05 18:11:19.714883	2025-11-05 18:11:53.996121
70	LUXEMBOURG	luxembourg	other	2	1	2025-11-05 18:11:19.759477	Añadida masivamente desde spell check	2025-11-05 18:11:19.759477	2025-11-05 18:11:54.040198
71	ALGER	alger	other	2	1	2025-11-05 18:11:19.810242	Añadida masivamente desde spell check	2025-11-05 18:11:19.810242	2025-11-05 18:11:54.090214
72	DEUTSCHE	deutsche	other	2	1	2025-11-05 18:11:19.861833	Añadida masivamente desde spell check	2025-11-05 18:11:19.861833	2025-11-05 18:11:54.13425
73	HSBC	hsbc	other	2	1	2025-11-05 18:11:19.913758	Añadida masivamente desde spell check	2025-11-05 18:11:19.913758	2025-11-05 18:11:54.183254
74	REYL	reyl	other	2	1	2025-11-05 18:11:19.966595	Añadida masivamente desde spell check	2025-11-05 18:11:19.966595	2025-11-05 18:11:54.232942
75	ALKEN	alken	other	2	1	2025-11-05 18:11:20.016084	Añadida masivamente desde spell check	2025-11-05 18:11:20.016084	2025-11-05 18:11:54.285033
14	Morningstar	morningstar	other	20	\N	2025-11-05 17:22:49.309849	Añadida masivamente desde spell check	2025-11-05 17:22:49.309849	2025-11-05 18:12:09.811528
10	España	españa	other	34	\N	2025-11-05 17:22:49.309849	Añadida masivamente desde spell check	2025-11-05 17:22:49.309849	2025-11-05 18:12:09.896328
135	ROWE	rowe	other	4	1	2025-11-05 18:11:23.841667	Añadida masivamente desde spell check	2025-11-05 18:11:23.841667	2025-11-05 18:12:18.109001
137	PRICE	price	other	4	1	2025-11-05 18:11:23.891383	Añadida masivamente desde spell check	2025-11-05 18:11:23.891383	2025-11-05 18:12:18.174598
76	CREDIT	credit	other	5	1	2025-11-05 18:11:20.068936	Añadida masivamente desde spell check	2025-11-05 18:11:20.068936	2025-11-05 18:12:26.281325
116	EVLI	evli	other	5	1	2025-11-05 18:11:21.950813	Añadida masivamente desde spell check	2025-11-05 18:11:21.950813	2025-11-05 18:12:26.557451
47	Fund	fund	other	5	1	2025-11-05 17:55:24.338372	Añadida masivamente desde spell check	2025-11-05 17:55:24.338372	2025-11-05 18:12:26.835994
112	LEGG	legg	other	5	1	2025-11-05 18:11:21.777947	Añadida masivamente desde spell check	2025-11-05 18:11:21.777947	2025-11-05 18:12:26.974164
84	INVESTMENT	investment	other	4	1	2025-11-05 18:11:20.471918	Añadida masivamente desde spell check	2025-11-05 18:11:20.471918	2025-11-05 18:12:27.236524
16	Vanguard	vanguard	other	13	\N	2025-11-05 17:22:49.309849	Añadida masivamente desde spell check	2025-11-05 17:22:49.309849	2025-11-05 18:12:27.560566
1	mail	mail	other	107	\N	2025-11-05 17:22:49.309849	Añadida masivamente desde spell check	2025-11-05 17:22:49.309849	2025-11-05 18:12:27.745044
130	Flórez	flórez	other	2	1	2025-11-05 18:11:23.676779	Añadida masivamente desde spell check	2025-11-05 18:11:23.676779	2025-11-05 18:11:42.811255
132	Álava	álava	other	2	1	2025-11-05 18:11:23.748695	Añadida masivamente desde spell check	2025-11-05 18:11:23.748695	2025-11-05 18:11:42.874698
134	Gasteiz	gasteiz	other	2	1	2025-11-05 18:11:23.816283	Añadida masivamente desde spell check	2025-11-05 18:11:23.816283	2025-11-05 18:11:42.934231
136	Albacete	albacete	other	2	1	2025-11-05 18:11:23.873096	Añadida masivamente desde spell check	2025-11-05 18:11:23.873096	2025-11-05 18:11:42.996633
138	Tesifonte	tesifonte	other	2	1	2025-11-05 18:11:23.919304	Añadida masivamente desde spell check	2025-11-05 18:11:23.919304	2025-11-05 18:11:43.044595
140	Óscar	óscar	other	2	1	2025-11-05 18:11:23.969332	Añadida masivamente desde spell check	2025-11-05 18:11:23.969332	2025-11-05 18:11:43.091758
79	DNCA	dnca	other	2	1	2025-11-05 18:11:20.223624	Añadida masivamente desde spell check	2025-11-05 18:11:20.223624	2025-11-05 18:11:54.472694
80	INVEST	invest	other	2	1	2025-11-05 18:11:20.279007	Añadida masivamente desde spell check	2025-11-05 18:11:20.279007	2025-11-05 18:11:54.517863
81	IGNIS	ignis	other	2	1	2025-11-05 18:11:20.327923	Añadida masivamente desde spell check	2025-11-05 18:11:20.327923	2025-11-05 18:11:54.569353
82	ROTSCHILD	rotschild	other	2	1	2025-11-05 18:11:20.3725	Añadida masivamente desde spell check	2025-11-05 18:11:20.3725	2025-11-05 18:11:54.614696
83	ALLIANZ	allianz	other	2	1	2025-11-05 18:11:20.422916	Añadida masivamente desde spell check	2025-11-05 18:11:20.422916	2025-11-05 18:11:54.66085
85	INVESCO	invesco	other	2	1	2025-11-05 18:11:20.5217	Añadida masivamente desde spell check	2025-11-05 18:11:20.5217	2025-11-05 18:11:54.749366
86	AMIRAL	amiral	other	2	1	2025-11-05 18:11:20.5723	Añadida masivamente desde spell check	2025-11-05 18:11:20.5723	2025-11-05 18:11:54.7986
87	GESTION	gestion	other	2	1	2025-11-05 18:11:20.618645	Añadida masivamente desde spell check	2025-11-05 18:11:20.618645	2025-11-05 18:11:54.843754
88	EAST	east	other	2	1	2025-11-05 18:11:20.667923	Añadida masivamente desde spell check	2025-11-05 18:11:20.667923	2025-11-05 18:11:54.887419
89	INVESTEC	investec	other	2	1	2025-11-05 18:11:20.715553	Añadida masivamente desde spell check	2025-11-05 18:11:20.715553	2025-11-05 18:11:54.928348
90	RUFFER	ruffer	other	2	1	2025-11-05 18:11:20.762395	Añadida masivamente desde spell check	2025-11-05 18:11:20.762395	2025-11-05 18:11:54.973035
92	EATON	eaton	other	2	1	2025-11-05 18:11:20.848923	Añadida masivamente desde spell check	2025-11-05 18:11:20.848923	2025-11-05 18:11:55.063432
93	VANCE	vance	other	2	1	2025-11-05 18:11:20.893416	Añadida masivamente desde spell check	2025-11-05 18:11:20.893416	2025-11-05 18:11:55.106841
94	JANUS	janus	other	2	1	2025-11-05 18:11:20.933314	Añadida masivamente desde spell check	2025-11-05 18:11:20.933314	2025-11-05 18:11:55.14828
96	ARGONAUT	argonaut	other	2	1	2025-11-05 18:11:21.01385	Añadida masivamente desde spell check	2025-11-05 18:11:21.01385	2025-11-05 18:11:55.239184
97	INTERNATIONAL	international	other	2	1	2025-11-05 18:11:21.064803	Añadida masivamente desde spell check	2025-11-05 18:11:21.064803	2025-11-05 18:11:55.2814
99	SCHRODER	schroder	other	2	1	2025-11-05 18:11:21.145344	Añadida masivamente desde spell check	2025-11-05 18:11:21.145344	2025-11-05 18:11:55.37395
100	ARTEMIS	artemis	other	2	1	2025-11-05 18:11:21.184835	Añadida masivamente desde spell check	2025-11-05 18:11:21.184835	2025-11-05 18:11:55.423632
101	EDMOND	edmond	other	2	1	2025-11-05 18:11:21.22674	Añadida masivamente desde spell check	2025-11-05 18:11:21.22674	2025-11-05 18:11:55.47472
102	JYSKE	jyske	other	2	1	2025-11-05 18:11:21.26984	Añadida masivamente desde spell check	2025-11-05 18:11:21.26984	2025-11-05 18:11:55.524538
103	HAMES	hames	other	2	1	2025-11-05 18:11:21.314629	Añadida masivamente desde spell check	2025-11-05 18:11:21.314629	2025-11-05 18:11:55.579302
104	SPARINVEST	sparinvest	other	2	1	2025-11-05 18:11:21.363705	Añadida masivamente desde spell check	2025-11-05 18:11:21.363705	2025-11-05 18:11:55.630714
105	ETHENEA	ethenea	other	2	1	2025-11-05 18:11:21.418856	Añadida masivamente desde spell check	2025-11-05 18:11:21.418856	2025-11-05 18:11:55.681393
106	LAZARD	lazard	other	2	1	2025-11-05 18:11:21.477031	Añadida masivamente desde spell check	2025-11-05 18:11:21.477031	2025-11-05 18:11:55.724905
107	STANDAR	standar	other	2	1	2025-11-05 18:11:21.538346	Añadida masivamente desde spell check	2025-11-05 18:11:21.538346	2025-11-05 18:11:55.769484
108	CHARTERED	chartered	other	2	1	2025-11-05 18:11:21.594564	Añadida masivamente desde spell check	2025-11-05 18:11:21.594564	2025-11-05 18:11:55.815235
109	INVESTMENTS	investments	other	2	1	2025-11-05 18:11:21.644808	Añadida masivamente desde spell check	2025-11-05 18:11:21.644808	2025-11-05 18:11:55.862539
110	BANTLEON	bantleon	other	2	1	2025-11-05 18:11:21.687173	Añadida masivamente desde spell check	2025-11-05 18:11:21.687173	2025-11-05 18:11:55.904566
111	EURIZON	eurizon	other	2	1	2025-11-05 18:11:21.733258	Añadida masivamente desde spell check	2025-11-05 18:11:21.733258	2025-11-05 18:11:55.946722
113	MANSON	manson	other	2	1	2025-11-05 18:11:21.822748	Añadida masivamente desde spell check	2025-11-05 18:11:21.822748	2025-11-05 18:11:56.033473
115	BARING	baring	other	2	1	2025-11-05 18:11:21.908778	Añadida masivamente desde spell check	2025-11-05 18:11:21.908778	2025-11-05 18:11:56.123771
117	LIONTRUST	liontrust	other	2	1	2025-11-05 18:11:21.992347	Añadida masivamente desde spell check	2025-11-05 18:11:21.992347	2025-11-05 18:11:56.214858
118	STATE	state	other	2	1	2025-11-05 18:11:22.036849	Añadida masivamente desde spell check	2025-11-05 18:11:22.036849	2025-11-05 18:11:56.260508
119	STREET	street	other	2	1	2025-11-05 18:11:22.081654	Añadida masivamente desde spell check	2025-11-05 18:11:22.081654	2025-11-05 18:11:56.309465
120	FRANCE	france	other	2	1	2025-11-05 18:11:22.126901	Añadida masivamente desde spell check	2025-11-05 18:11:22.126901	2025-11-05 18:11:56.351019
122	EXANE	exane	other	2	1	2025-11-05 18:11:22.250988	Añadida masivamente desde spell check	2025-11-05 18:11:22.250988	2025-11-05 18:11:56.436493
123	LOMBARD	lombard	other	2	1	2025-11-05 18:11:22.309765	Añadida masivamente desde spell check	2025-11-05 18:11:22.309765	2025-11-05 18:11:56.478375
124	SWIP	swip	other	2	1	2025-11-05 18:11:22.365015	Añadida masivamente desde spell check	2025-11-05 18:11:22.365015	2025-11-05 18:11:56.521688
125	FEROX	ferox	other	2	1	2025-11-05 18:11:22.419125	Añadida masivamente desde spell check	2025-11-05 18:11:22.419125	2025-11-05 18:11:56.56883
126	MAGLLANES	magllanes	other	2	1	2025-11-05 18:11:22.462641	Añadida masivamente desde spell check	2025-11-05 18:11:22.462641	2025-11-05 18:11:56.614389
127	SYCOMORE	sycomore	other	2	1	2025-11-05 18:11:22.503711	Añadida masivamente desde spell check	2025-11-05 18:11:22.503711	2025-11-05 18:11:56.656948
128	BLUEBAY	bluebay	other	2	1	2025-11-05 18:11:22.547596	Añadida masivamente desde spell check	2025-11-05 18:11:22.547596	2025-11-05 18:11:56.700155
131	INVESTMENTES	investmentes	other	2	1	2025-11-05 18:11:23.690204	Añadida masivamente desde spell check	2025-11-05 18:11:23.690204	2025-11-05 18:11:56.786453
133	MANDARINE	mandarine	other	2	1	2025-11-05 18:11:23.759171	Añadida masivamente desde spell check	2025-11-05 18:11:23.759171	2025-11-05 18:11:56.83243
139	DIDENTIS	didentis	other	2	1	2025-11-05 18:11:23.940426	Añadida masivamente desde spell check	2025-11-05 18:11:23.940426	2025-11-05 18:11:56.965925
141	MATTHEWS	matthews	other	2	1	2025-11-05 18:11:23.99097	Añadida masivamente desde spell check	2025-11-05 18:11:23.99097	2025-11-05 18:11:57.008916
33	anualizada	anualizada	other	5	1	2025-11-05 17:54:58.228539	Añadida masivamente desde spell check	2025-11-05 17:54:58.228539	2025-11-05 18:12:25.643055
98	MORGAN	morgan	other	6	1	2025-11-05 18:11:21.105353	Añadida masivamente desde spell check	2025-11-05 18:11:21.105353	2025-11-05 18:12:26.879641
185	BERMAN	berman	other	5	1	2025-11-05 18:11:25.274133	Añadida masivamente desde spell check	2025-11-05 18:11:25.274133	2025-11-05 18:12:27.325324
761	ASML	asml	other	1	1	2025-11-05 18:33:31.191643	Añadida masivamente desde spell check	2025-11-05 18:33:31.191643	2025-11-05 18:33:31.191643
142	Esplá	esplá	other	2	1	2025-11-05 18:11:24.017939	Añadida masivamente desde spell check	2025-11-05 18:11:24.017939	2025-11-05 18:11:43.137249
144	Almería	almería	other	2	1	2025-11-05 18:11:24.071275	Añadida masivamente desde spell check	2025-11-05 18:11:24.071275	2025-11-05 18:11:43.185195
146	Federico	federico	other	2	1	2025-11-05 18:11:24.122675	Añadida masivamente desde spell check	2025-11-05 18:11:24.122675	2025-11-05 18:11:43.229953
148	Lorca	lorca	other	2	1	2025-11-05 18:11:24.177646	Añadida masivamente desde spell check	2025-11-05 18:11:24.177646	2025-11-05 18:11:43.29285
150	Asturias	asturias	other	2	1	2025-11-05 18:11:24.243723	Añadida masivamente desde spell check	2025-11-05 18:11:24.243723	2025-11-05 18:11:43.344339
152	Gijón	gijón	other	2	1	2025-11-05 18:11:24.315116	Añadida masivamente desde spell check	2025-11-05 18:11:24.315116	2025-11-05 18:11:43.404054
154	Donato	donato	other	2	1	2025-11-05 18:11:24.378753	Añadida masivamente desde spell check	2025-11-05 18:11:24.378753	2025-11-05 18:11:43.450982
158	Oviedo	oviedo	other	2	1	2025-11-05 18:11:24.51939	Añadida masivamente desde spell check	2025-11-05 18:11:24.51939	2025-11-05 18:11:43.542008
160	Uría	uría	other	2	1	2025-11-05 18:11:24.586223	Añadida masivamente desde spell check	2025-11-05 18:11:24.586223	2025-11-05 18:11:43.592822
162	Ávila	ávila	other	2	1	2025-11-05 18:11:24.638657	Añadida masivamente desde spell check	2025-11-05 18:11:24.638657	2025-11-05 18:11:43.635965
164	Badajoz	badajoz	other	2	1	2025-11-05 18:11:24.691608	Añadida masivamente desde spell check	2025-11-05 18:11:24.691608	2025-11-05 18:11:43.680819
166	Valdivia	valdivia	other	2	1	2025-11-05 18:11:24.747473	Añadida masivamente desde spell check	2025-11-05 18:11:24.747473	2025-11-05 18:11:43.724461
168	Mallorca	mallorca	other	2	1	2025-11-05 18:11:24.798783	Añadida masivamente desde spell check	2025-11-05 18:11:24.798783	2025-11-05 18:11:43.77322
170	Avinguda	avinguda	other	2	1	2025-11-05 18:11:24.846831	Añadida masivamente desde spell check	2025-11-05 18:11:24.846831	2025-11-05 18:11:43.828379
172	Comte	comte	other	2	1	2025-11-05 18:11:24.897143	Añadida masivamente desde spell check	2025-11-05 18:11:24.897143	2025-11-05 18:11:43.878864
174	Sallent	sallent	other	2	1	2025-11-05 18:11:24.946959	Añadida masivamente desde spell check	2025-11-05 18:11:24.946959	2025-11-05 18:11:43.928992
13	Barcelona	barcelona	other	10	\N	2025-11-05 17:22:49.309849	Añadida masivamente desde spell check	2025-11-05 17:22:49.309849	2025-11-05 18:11:43.981304
178	Corts	corts	other	2	1	2025-11-05 18:11:25.053222	Añadida masivamente desde spell check	2025-11-05 18:11:25.053222	2025-11-05 18:11:44.031335
180	Sabadell	sabadell	other	2	1	2025-11-05 18:11:25.126469	Añadida masivamente desde spell check	2025-11-05 18:11:25.126469	2025-11-05 18:11:44.090797
182	Carrer	carrer	other	2	1	2025-11-05 18:11:25.188057	Añadida masivamente desde spell check	2025-11-05 18:11:25.188057	2025-11-05 18:11:44.142408
184	Creus	creus	other	2	1	2025-11-05 18:11:25.251457	Añadida masivamente desde spell check	2025-11-05 18:11:25.251457	2025-11-05 18:11:44.191732
186	Terrassa	terrassa	other	2	1	2025-11-05 18:11:25.312671	Añadida masivamente desde spell check	2025-11-05 18:11:25.312671	2025-11-05 18:11:44.240964
188	Sant	sant	other	2	1	2025-11-05 18:11:25.365281	Añadida masivamente desde spell check	2025-11-05 18:11:25.365281	2025-11-05 18:11:44.287872
190	Leopold	leopold	other	2	1	2025-11-05 18:11:25.415179	Añadida masivamente desde spell check	2025-11-05 18:11:25.415179	2025-11-05 18:11:44.342437
192	Cáceres	cáceres	other	2	1	2025-11-05 18:11:25.466515	Añadida masivamente desde spell check	2025-11-05 18:11:25.466515	2025-11-05 18:11:44.393717
194	Guadalupe	guadalupe	other	2	1	2025-11-05 18:11:25.520451	Añadida masivamente desde spell check	2025-11-05 18:11:25.520451	2025-11-05 18:11:44.441329
196	Cádiz	cádiz	other	2	1	2025-11-05 18:11:25.576192	Añadida masivamente desde spell check	2025-11-05 18:11:25.576192	2025-11-05 18:11:44.49152
198	Jiménez	jiménez	other	2	1	2025-11-05 18:11:25.629928	Añadida masivamente desde spell check	2025-11-05 18:11:25.629928	2025-11-05 18:11:44.539509
200	Andalucia	andalucia	other	2	1	2025-11-05 18:11:25.682402	Añadida masivamente desde spell check	2025-11-05 18:11:25.682402	2025-11-05 18:11:44.589514
202	Cantabria	cantabria	other	2	1	2025-11-05 18:11:25.740935	Añadida masivamente desde spell check	2025-11-05 18:11:25.740935	2025-11-05 18:11:44.641382
204	Isabel	isabel	other	2	1	2025-11-05 18:11:25.811156	Añadida masivamente desde spell check	2025-11-05 18:11:25.811156	2025-11-05 18:11:44.693039
143	TRHEADNEEDLE	trheadneedle	other	2	1	2025-11-05 18:11:24.04288	Añadida masivamente desde spell check	2025-11-05 18:11:24.04288	2025-11-05 18:11:57.056046
145	PARIBAS	paribas	other	2	1	2025-11-05 18:11:24.08964	Añadida masivamente desde spell check	2025-11-05 18:11:24.08964	2025-11-05 18:11:57.099719
147	FINANCIERE	financiere	other	2	1	2025-11-05 18:11:24.139084	Añadida masivamente desde spell check	2025-11-05 18:11:24.139084	2025-11-05 18:11:57.14498
149	LECHIQUIER	lechiquier	other	2	1	2025-11-05 18:11:24.190358	Añadida masivamente desde spell check	2025-11-05 18:11:24.190358	2025-11-05 18:11:57.189534
151	MERCHBANC	merchbanc	other	2	1	2025-11-05 18:11:24.261834	Añadida masivamente desde spell check	2025-11-05 18:11:24.261834	2025-11-05 18:11:57.233432
153	UBAM	ubam	other	2	1	2025-11-05 18:11:24.334022	Añadida masivamente desde spell check	2025-11-05 18:11:24.334022	2025-11-05 18:11:57.274888
155	MELLON	mellon	other	2	1	2025-11-05 18:11:24.402293	Añadida masivamente desde spell check	2025-11-05 18:11:24.402293	2025-11-05 18:11:57.320889
161	FLAB	flab	other	2	1	2025-11-05 18:11:24.60311	Añadida masivamente desde spell check	2025-11-05 18:11:24.60311	2025-11-05 18:11:57.455411
163	BRANDES	brandes	other	2	1	2025-11-05 18:11:24.654021	Añadida masivamente desde spell check	2025-11-05 18:11:24.654021	2025-11-05 18:11:57.502002
165	FLOSSBACH	flossbach	other	2	1	2025-11-05 18:11:24.708419	Añadida masivamente desde spell check	2025-11-05 18:11:24.708419	2025-11-05 18:11:57.544053
169	BROWN	brown	other	2	1	2025-11-05 18:11:24.814318	Añadida masivamente desde spell check	2025-11-05 18:11:24.814318	2025-11-05 18:11:57.632211
171	ADVISORY	advisory	other	2	1	2025-11-05 18:11:24.862428	Añadida masivamente desde spell check	2025-11-05 18:11:24.862428	2025-11-05 18:11:57.694208
173	TEMPLETON	templeton	other	2	1	2025-11-05 18:11:24.913387	Añadida masivamente desde spell check	2025-11-05 18:11:24.913387	2025-11-05 18:11:57.739846
175	MUZINICH	muzinich	other	2	1	2025-11-05 18:11:24.963117	Añadida masivamente desde spell check	2025-11-05 18:11:24.963117	2025-11-05 18:11:57.787597
177	UNIGESTION	unigestion	other	2	1	2025-11-05 18:11:25.016715	Añadida masivamente desde spell check	2025-11-05 18:11:25.016715	2025-11-05 18:11:57.835625
179	CANDRIAM	candriam	other	2	1	2025-11-05 18:11:25.080196	Añadida masivamente desde spell check	2025-11-05 18:11:25.080196	2025-11-05 18:11:57.884057
181	FULCRUM	fulcrum	other	2	1	2025-11-05 18:11:25.145431	Añadida masivamente desde spell check	2025-11-05 18:11:25.145431	2025-11-05 18:11:57.929556
187	UNION	union	other	2	1	2025-11-05 18:11:25.328549	Añadida masivamente desde spell check	2025-11-05 18:11:25.328549	2025-11-05 18:11:58.059476
189	WORK	work	other	2	1	2025-11-05 18:11:25.383955	Añadida masivamente desde spell check	2025-11-05 18:11:25.383955	2025-11-05 18:11:58.104887
191	NOMURA	nomura	other	2	1	2025-11-05 18:11:25.441777	Añadida masivamente desde spell check	2025-11-05 18:11:25.441777	2025-11-05 18:11:58.147482
193	VONTOBEL	vontobel	other	2	1	2025-11-05 18:11:25.504653	Añadida masivamente desde spell check	2025-11-05 18:11:25.504653	2025-11-05 18:11:58.18935
195	GROUP	group	other	2	1	2025-11-05 18:11:25.561723	Añadida masivamente desde spell check	2025-11-05 18:11:25.561723	2025-11-05 18:11:58.230268
197	GAMAX	gamax	other	2	1	2025-11-05 18:11:25.614377	Añadida masivamente desde spell check	2025-11-05 18:11:25.614377	2025-11-05 18:11:58.272842
199	ODDO	oddo	other	2	1	2025-11-05 18:11:25.668403	Añadida masivamente desde spell check	2025-11-05 18:11:25.668403	2025-11-05 18:11:58.318623
201	WAVERTON	waverton	other	2	1	2025-11-05 18:11:25.727628	Añadida masivamente desde spell check	2025-11-05 18:11:25.727628	2025-11-05 18:11:58.361425
157	FIRST	first	other	3	1	2025-11-05 18:11:24.472487	Añadida masivamente desde spell check	2025-11-05 18:11:24.472487	2025-11-05 18:12:08.444932
887	crash	crash	other	1	1	2025-11-05 18:37:10.379419	Añadida masivamente desde spell check	2025-11-05 18:37:10.379419	2025-11-05 18:37:10.379419
689	JPMorgan	jpmorgan	other	1	1	2025-11-05 18:12:17.516435	Añadida masivamente desde spell check	2025-11-05 18:12:17.516435	2025-11-05 18:12:17.516435
11	Europa	europa	other	25	\N	2025-11-05 17:22:49.309849	Añadida masivamente desde spell check	2025-11-05 17:22:49.309849	2025-11-05 18:12:26.42871
203	CARMIGNAC	carmignac	other	5	1	2025-11-05 18:11:25.794462	Añadida masivamente desde spell check	2025-11-05 18:11:25.794462	2025-11-05 18:12:26.471781
277	Securite	securite	other	3	1	2025-11-05 18:11:28.409888	Añadida masivamente desde spell check	2025-11-05 18:11:28.409888	2025-11-05 18:12:26.514462
283	Nordic	nordic	other	3	1	2025-11-05 18:11:28.54248	Añadida masivamente desde spell check	2025-11-05 18:11:28.54248	2025-11-05 18:12:26.607791
285	Corporate	corporate	other	4	1	2025-11-05 18:11:30.002538	Añadida masivamente desde spell check	2025-11-05 18:11:30.002538	2025-11-05 18:12:26.654546
287	Bond	bond	other	4	1	2025-11-05 18:11:30.07565	Añadida masivamente desde spell check	2025-11-05 18:11:30.07565	2025-11-05 18:12:26.697674
208	Castellón	castellón	other	2	1	2025-11-05 18:11:25.924399	Añadida masivamente desde spell check	2025-11-05 18:11:25.924399	2025-11-05 18:11:44.79535
210	Gasset	gasset	other	2	1	2025-11-05 18:11:25.988386	Añadida masivamente desde spell check	2025-11-05 18:11:25.988386	2025-11-05 18:11:44.84623
212	Girona	girona	other	2	1	2025-11-05 18:11:26.055057	Añadida masivamente desde spell check	2025-11-05 18:11:26.055057	2025-11-05 18:11:44.890674
215	Venegas	venegas	other	2	1	2025-11-05 18:11:26.156897	Añadida masivamente desde spell check	2025-11-05 18:11:26.156897	2025-11-05 18:11:44.991324
218	Darro	darro	other	2	1	2025-11-05 18:11:27.086418	Añadida masivamente desde spell check	2025-11-05 18:11:27.086418	2025-11-05 18:11:45.039895
221	Guadalajara	guadalajara	other	2	1	2025-11-05 18:11:27.15378	Añadida masivamente desde spell check	2025-11-05 18:11:27.15378	2025-11-05 18:11:45.092725
224	Félix	félix	other	2	1	2025-11-05 18:11:27.214936	Añadida masivamente desde spell check	2025-11-05 18:11:27.214936	2025-11-05 18:11:45.145187
227	Guipúzcoa	guipúzcoa	other	2	1	2025-11-05 18:11:27.278299	Añadida masivamente desde spell check	2025-11-05 18:11:27.278299	2025-11-05 18:11:45.194078
230	Gipuzkoa	gipuzkoa	other	2	1	2025-11-05 18:11:27.338488	Añadida masivamente desde spell check	2025-11-05 18:11:27.338488	2025-11-05 18:11:45.244464
233	Urbieta	urbieta	other	2	1	2025-11-05 18:11:27.401646	Añadida masivamente desde spell check	2025-11-05 18:11:27.401646	2025-11-05 18:11:45.302451
236	Sebastián	sebastián	other	2	1	2025-11-05 18:11:27.458351	Añadida masivamente desde spell check	2025-11-05 18:11:27.458351	2025-11-05 18:11:45.350149
240	Huelva	huelva	other	2	1	2025-11-05 18:11:27.533488	Añadida masivamente desde spell check	2025-11-05 18:11:27.533488	2025-11-05 18:11:45.397756
243	Huesca	huesca	other	2	1	2025-11-05 18:11:27.607733	Añadida masivamente desde spell check	2025-11-05 18:11:27.607733	2025-11-05 18:11:45.44559
246	Cavia	cavia	other	2	1	2025-11-05 18:11:27.677413	Añadida masivamente desde spell check	2025-11-05 18:11:27.677413	2025-11-05 18:11:45.49621
251	Logroño	logroño	other	2	1	2025-11-05 18:11:27.828004	Añadida masivamente desde spell check	2025-11-05 18:11:27.828004	2025-11-05 18:11:45.604996
254	Portugal	portugal	other	2	1	2025-11-05 18:11:27.892095	Añadida masivamente desde spell check	2025-11-05 18:11:27.892095	2025-11-05 18:11:45.66045
257	Lanzarote	lanzarote	other	2	1	2025-11-05 18:11:27.954082	Añadida masivamente desde spell check	2025-11-05 18:11:27.954082	2025-11-05 18:11:45.718567
260	Lleida	lleida	other	2	1	2025-11-05 18:11:28.022124	Añadida masivamente desde spell check	2025-11-05 18:11:28.022124	2025-11-05 18:11:45.764156
263	Rovira	rovira	other	2	1	2025-11-05 18:11:28.095402	Añadida masivamente desde spell check	2025-11-05 18:11:28.095402	2025-11-05 18:11:45.81503
266	Roure	roure	other	2	1	2025-11-05 18:11:28.160121	Añadida masivamente desde spell check	2025-11-05 18:11:28.160121	2025-11-05 18:11:45.862515
269	Lugo	lugo	other	2	1	2025-11-05 18:11:28.218861	Añadida masivamente desde spell check	2025-11-05 18:11:28.218861	2025-11-05 18:11:45.918947
272	Perón	perón	other	2	1	2025-11-05 18:11:28.28629	Añadida masivamente desde spell check	2025-11-05 18:11:28.28629	2025-11-05 18:11:45.973764
275	Vergara	vergara	other	2	1	2025-11-05 18:11:28.351941	Añadida masivamente desde spell check	2025-11-05 18:11:28.351941	2025-11-05 18:11:46.024884
278	Principe	principe	other	2	1	2025-11-05 18:11:28.438193	Añadida masivamente desde spell check	2025-11-05 18:11:28.438193	2025-11-05 18:11:46.077426
281	Leganés	leganés	other	2	1	2025-11-05 18:11:28.516027	Añadida masivamente desde spell check	2025-11-05 18:11:28.516027	2025-11-05 18:11:46.121842
284	Fuenlabrada	fuenlabrada	other	2	1	2025-11-05 18:11:28.58973	Añadida masivamente desde spell check	2025-11-05 18:11:28.58973	2025-11-05 18:11:46.164784
286	Pamplona	pamplona	other	2	1	2025-11-05 18:11:30.002339	Añadida masivamente desde spell check	2025-11-05 18:11:30.002339	2025-11-05 18:11:46.206648
288	Ourense	ourense	other	2	1	2025-11-05 18:11:30.085357	Añadida masivamente desde spell check	2025-11-05 18:11:30.085357	2025-11-05 18:11:46.248425
95	SANTANDER	santander	other	4	1	2025-11-05 18:11:20.973432	Añadida masivamente desde spell check	2025-11-05 18:11:20.973432	2025-11-05 18:11:55.195223
205	ODEY	odey	other	2	1	2025-11-05 18:11:25.857964	Añadida masivamente desde spell check	2025-11-05 18:11:25.857964	2025-11-05 18:11:58.444513
207	WELLS	wells	other	2	1	2025-11-05 18:11:25.922708	Añadida masivamente desde spell check	2025-11-05 18:11:25.922708	2025-11-05 18:11:58.486968
209	FARGO	fargo	other	2	1	2025-11-05 18:11:25.988079	Añadida masivamente desde spell check	2025-11-05 18:11:25.988079	2025-11-05 18:11:58.52914
214	GENERALI	generali	other	2	1	2025-11-05 18:11:26.112743	Añadida masivamente desde spell check	2025-11-05 18:11:26.112743	2025-11-05 18:11:58.61625
216	OYSTER	oyster	other	2	1	2025-11-05 18:11:26.161626	Añadida masivamente desde spell check	2025-11-05 18:11:26.161626	2025-11-05 18:11:58.657865
219	WEST	west	other	2	1	2025-11-05 18:11:27.091178	Añadida masivamente desde spell check	2025-11-05 18:11:27.091178	2025-11-05 18:11:58.699553
222	COLLANDER	collander	other	2	1	2025-11-05 18:11:27.157289	Añadida masivamente desde spell check	2025-11-05 18:11:27.157289	2025-11-05 18:11:58.740177
225	PARTNERS	partners	other	2	1	2025-11-05 18:11:27.225584	Añadida masivamente desde spell check	2025-11-05 18:11:27.225584	2025-11-05 18:11:58.782928
228	PETERCAM	petercam	other	2	1	2025-11-05 18:11:27.288741	Añadida masivamente desde spell check	2025-11-05 18:11:27.288741	2025-11-05 18:11:58.830016
231	ZEST	zest	other	2	1	2025-11-05 18:11:27.340329	Añadida masivamente desde spell check	2025-11-05 18:11:27.340329	2025-11-05 18:11:58.872495
234	COMGEST	comgest	other	2	1	2025-11-05 18:11:27.402343	Añadida masivamente desde spell check	2025-11-05 18:11:27.402343	2025-11-05 18:11:58.91502
237	GOLDMAN	goldman	other	2	1	2025-11-05 18:11:27.459955	Añadida masivamente desde spell check	2025-11-05 18:11:27.459955	2025-11-05 18:11:58.957135
239	SACHS	sachs	other	2	1	2025-11-05 18:11:27.527072	Añadida masivamente desde spell check	2025-11-05 18:11:27.527072	2025-11-05 18:11:58.999247
242	PIMCO	pimco	other	2	1	2025-11-05 18:11:27.598949	Añadida masivamente desde spell check	2025-11-05 18:11:27.598949	2025-11-05 18:11:59.040239
245	GROUPAMA	groupama	other	2	1	2025-11-05 18:11:27.675157	Añadida masivamente desde spell check	2025-11-05 18:11:27.675157	2025-11-05 18:11:59.08752
249	PINEBRIDGE	pinebridge	other	2	1	2025-11-05 18:11:27.761639	Añadida masivamente desde spell check	2025-11-05 18:11:27.761639	2025-11-05 18:11:59.129401
252	SUISSE	suisse	other	2	1	2025-11-05 18:11:27.83974	Añadida masivamente desde spell check	2025-11-05 18:11:27.83974	2025-11-05 18:11:59.171954
255	CYGNUS	cygnus	other	2	1	2025-11-05 18:11:27.903725	Añadida masivamente desde spell check	2025-11-05 18:11:27.903725	2025-11-05 18:11:59.214802
258	PUTNAM	putnam	other	2	1	2025-11-05 18:11:27.968654	Añadida masivamente desde spell check	2025-11-05 18:11:27.968654	2025-11-05 18:11:59.257655
261	multidivisa	multidivisa	other	2	1	2025-11-05 18:11:28.03056	Añadida masivamente desde spell check	2025-11-05 18:11:28.03056	2025-11-05 18:11:59.303319
264	desinversiones	desinversiones	other	2	1	2025-11-05 18:11:28.102161	Añadida masivamente desde spell check	2025-11-05 18:11:28.102161	2025-11-05 18:11:59.345726
267	reembolsos	reembolsos	other	2	1	2025-11-05 18:11:28.171432	Añadida masivamente desde spell check	2025-11-05 18:11:28.171432	2025-11-05 18:11:59.388288
270	Fondotop	fondotop	other	2	1	2025-11-05 18:11:28.234801	Añadida masivamente desde spell check	2025-11-05 18:11:28.234801	2025-11-05 18:11:59.429533
282	PRIIPS	priips	other	2	1	2025-11-05 18:11:28.527659	Añadida masivamente desde spell check	2025-11-05 18:11:28.527659	2025-11-05 18:11:59.600654
296	Jupiter	jupiter	other	3	1	2025-11-05 18:11:30.305406	Añadida masivamente desde spell check	2025-11-05 18:11:30.305406	2025-11-05 18:12:17.56838
320	Growth	growth	other	3	1	2025-11-05 18:11:31.129437	Añadida masivamente desde spell check	2025-11-05 18:11:31.129437	2025-11-05 18:12:17.82876
367	Smaller	smaller	other	2	1	2025-11-05 18:11:36.141691	Añadida masivamente desde spell check	2025-11-05 18:11:36.141691	2025-11-05 18:12:18.238775
368	Companies	companies	other	2	1	2025-11-05 18:11:36.1826	Añadida masivamente desde spell check	2025-11-05 18:11:36.1826	2025-11-05 18:12:18.301397
40	Funds	funds	other	7	1	2025-11-05 17:55:11.197998	Añadida masivamente desde spell check	2025-11-05 17:55:11.197998	2025-11-05 18:12:26.024358
291	Income	income	other	4	1	2025-11-05 18:11:30.202665	Añadida masivamente desde spell check	2025-11-05 18:11:30.202665	2025-11-05 18:12:26.787574
738	Europe	europe	other	1	1	2025-11-05 18:12:26.927195	Añadida masivamente desde spell check	2025-11-05 18:12:26.927195	2025-11-05 18:12:26.927195
302	ClearBridge	clearbridge	other	4	1	2025-11-05 18:11:30.49972	Añadida masivamente desde spell check	2025-11-05 18:11:30.49972	2025-11-05 18:12:27.06117
304	Value	value	other	4	1	2025-11-05 18:11:30.57128	Añadida masivamente desde spell check	2025-11-05 18:11:30.57128	2025-11-05 18:12:27.10713
306	Meridian	meridian	other	3	1	2025-11-05 18:11:30.637325	Añadida masivamente desde spell check	2025-11-05 18:11:30.637325	2025-11-05 18:12:27.152878
167	STANLEY	stanley	other	6	1	2025-11-05 18:11:24.762628	Añadida masivamente desde spell check	2025-11-05 18:11:24.762628	2025-11-05 18:12:27.194619
316	Market	market	other	3	1	2025-11-05 18:11:30.984689	Añadida masivamente desde spell check	2025-11-05 18:11:30.984689	2025-11-05 18:12:27.368041
318	Debt	debt	other	3	1	2025-11-05 18:11:31.049533	Añadida masivamente desde spell check	2025-11-05 18:11:31.049533	2025-11-05 18:12:27.411598
363	Premium	premium	other	3	1	2025-11-05 18:11:35.97104	Añadida masivamente desde spell check	2025-11-05 18:11:35.97104	2025-11-05 18:12:27.459535
364	Equities	equities	other	3	1	2025-11-05 18:11:36.012065	Añadida masivamente desde spell check	2025-11-05 18:11:36.012065	2025-11-05 18:12:27.510712
370	Stock	stock	other	3	1	2025-11-05 18:11:36.266181	Añadida masivamente desde spell check	2025-11-05 18:11:36.266181	2025-11-05 18:12:27.611857
371	Index	index	other	3	1	2025-11-05 18:11:36.316754	Añadida masivamente desde spell check	2025-11-05 18:11:36.316754	2025-11-05 18:12:27.659535
25	carácteres	carácteres	other	107	\N	2025-11-05 17:22:49.309849	Añadida masivamente desde spell check	2025-11-05 17:22:49.309849	2025-11-05 18:12:27.702056
758	rentabilizar	rentabilizar	other	1	1	2025-11-05 18:33:30.989479	Añadida masivamente desde spell check	2025-11-05 18:33:30.989479	2025-11-05 18:33:30.989479
156	Argüelles	argüelles	other	2	1	2025-11-05 18:11:24.451913	Añadida masivamente desde spell check	2025-11-05 18:11:24.451913	2025-11-05 18:11:43.497491
213	Jaume	jaume	other	2	1	2025-11-05 18:11:26.110592	Añadida masivamente desde spell check	2025-11-05 18:11:26.110592	2025-11-05 18:11:44.941529
290	Enríquez	enríquez	other	2	1	2025-11-05 18:11:30.153588	Añadida masivamente desde spell check	2025-11-05 18:11:30.153588	2025-11-05 18:11:46.299801
292	Baixo	baixo	other	2	1	2025-11-05 18:11:30.204861	Añadida masivamente desde spell check	2025-11-05 18:11:30.204861	2025-11-05 18:11:46.353397
294	Palencia	palencia	other	2	1	2025-11-05 18:11:30.254263	Añadida masivamente desde spell check	2025-11-05 18:11:30.254263	2025-11-05 18:11:46.404818
295	Salamanca	salamanca	other	2	1	2025-11-05 18:11:30.303766	Añadida masivamente desde spell check	2025-11-05 18:11:30.303766	2025-11-05 18:11:46.451503
298	Mirat	mirat	other	2	1	2025-11-05 18:11:30.363928	Añadida masivamente desde spell check	2025-11-05 18:11:30.363928	2025-11-05 18:11:46.504588
299	Tenerife	tenerife	other	2	1	2025-11-05 18:11:30.423019	Añadida masivamente desde spell check	2025-11-05 18:11:30.423019	2025-11-05 18:11:46.551293
301	Segovia	segovia	other	2	1	2025-11-05 18:11:30.480315	Añadida masivamente desde spell check	2025-11-05 18:11:30.480315	2025-11-05 18:11:46.593153
303	Ezequiel	ezequiel	other	2	1	2025-11-05 18:11:30.544458	Añadida masivamente desde spell check	2025-11-05 18:11:30.544458	2025-11-05 18:11:46.634477
305	González	gonzález	other	2	1	2025-11-05 18:11:30.598444	Añadida masivamente desde spell check	2025-11-05 18:11:30.598444	2025-11-05 18:11:46.67587
307	Sevilla	sevilla	other	2	1	2025-11-05 18:11:30.662069	Añadida masivamente desde spell check	2025-11-05 18:11:30.662069	2025-11-05 18:11:46.71642
309	Buhaira	buhaira	other	2	1	2025-11-05 18:11:30.727106	Añadida masivamente desde spell check	2025-11-05 18:11:30.727106	2025-11-05 18:11:46.76033
311	Soria	soria	other	2	1	2025-11-05 18:11:30.791276	Añadida masivamente desde spell check	2025-11-05 18:11:30.791276	2025-11-05 18:11:46.807709
313	Teruel	teruel	other	2	1	2025-11-05 18:11:30.865086	Añadida masivamente desde spell check	2025-11-05 18:11:30.865086	2025-11-05 18:11:46.850275
315	Sagunto	sagunto	other	2	1	2025-11-05 18:11:30.930546	Añadida masivamente desde spell check	2025-11-05 18:11:30.930546	2025-11-05 18:11:46.898934
317	Toledo	toledo	other	2	1	2025-11-05 18:11:30.995135	Añadida masivamente desde spell check	2025-11-05 18:11:30.995135	2025-11-05 18:11:46.951972
319	Cullera	cullera	other	2	1	2025-11-05 18:11:31.068183	Añadida masivamente desde spell check	2025-11-05 18:11:31.068183	2025-11-05 18:11:47.004562
321	Passatge	passatge	other	2	1	2025-11-05 18:11:31.157677	Añadida masivamente desde spell check	2025-11-05 18:11:31.157677	2025-11-05 18:11:47.056562
461	Valladolid	valladolid	other	1	1	2025-11-05 18:11:47.107457	Añadida masivamente desde spell check	2025-11-05 18:11:47.107457	2025-11-05 18:11:47.107457
462	Miguel	miguel	other	1	1	2025-11-05 18:11:47.156863	Añadida masivamente desde spell check	2025-11-05 18:11:47.156863	2025-11-05 18:11:47.156863
463	Íscar	íscar	other	1	1	2025-11-05 18:11:47.20897	Añadida masivamente desde spell check	2025-11-05 18:11:47.20897	2025-11-05 18:11:47.20897
464	Vigo	vigo	other	1	1	2025-11-05 18:11:47.255974	Añadida masivamente desde spell check	2025-11-05 18:11:47.255974	2025-11-05 18:11:47.255974
465	Lepanto	lepanto	other	1	1	2025-11-05 18:11:47.307483	Añadida masivamente desde spell check	2025-11-05 18:11:47.307483	2025-11-05 18:11:47.307483
466	Vizcaya	vizcaya	other	1	1	2025-11-05 18:11:47.369505	Añadida masivamente desde spell check	2025-11-05 18:11:47.369505	2025-11-05 18:11:47.369505
467	Bilbao	bilbao	other	1	1	2025-11-05 18:11:47.428878	Añadida masivamente desde spell check	2025-11-05 18:11:47.428878	2025-11-05 18:11:47.428878
468	Elcano	elcano	other	1	1	2025-11-05 18:11:47.495739	Añadida masivamente desde spell check	2025-11-05 18:11:47.495739	2025-11-05 18:11:47.495739
469	Zamora	zamora	other	1	1	2025-11-05 18:11:47.561572	Añadida masivamente desde spell check	2025-11-05 18:11:47.561572	2025-11-05 18:11:47.561572
470	Alfonso	alfonso	other	1	1	2025-11-05 18:11:47.611194	Añadida masivamente desde spell check	2025-11-05 18:11:47.611194	2025-11-05 18:11:47.611194
471	Zaragoza	zaragoza	other	1	1	2025-11-05 18:11:47.654169	Añadida masivamente desde spell check	2025-11-05 18:11:47.654169	2025-11-05 18:11:47.654169
472	XIII	xiii	other	1	1	2025-11-05 18:11:47.695172	Añadida masivamente desde spell check	2025-11-05 18:11:47.695172	2025-11-05 18:11:47.695172
78	ALLIANCE	alliance	other	2	1	2025-11-05 18:11:20.170212	Añadida masivamente desde spell check	2025-11-05 18:11:20.170212	2025-11-05 18:11:54.427602
114	LIFE	life	other	2	1	2025-11-05 18:11:21.866847	Añadida masivamente desde spell check	2025-11-05 18:11:21.866847	2025-11-05 18:11:56.0813
159	METZLER	metzler	other	2	1	2025-11-05 18:11:24.53877	Añadida masivamente desde spell check	2025-11-05 18:11:24.53877	2025-11-05 18:11:57.411454
211	CARTESIO	cartesio	other	2	1	2025-11-05 18:11:26.053856	Añadida masivamente desde spell check	2025-11-05 18:11:26.053856	2025-11-05 18:11:58.574399
614	cripto	cripto	other	1	1	2025-11-05 18:12:07.641155	Añadida masivamente desde spell check	2025-11-05 18:12:07.641155	2025-11-05 18:12:07.641155
615	megatendencias	megatendencias	other	1	1	2025-11-05 18:12:07.705847	Añadida masivamente desde spell check	2025-11-05 18:12:07.705847	2025-11-05 18:12:07.705847
616	ETPs	etps	other	1	1	2025-11-05 18:12:07.772343	Añadida masivamente desde spell check	2025-11-05 18:12:07.772343	2025-11-05 18:12:07.772343
617	iShares	ishares	other	1	1	2025-11-05 18:12:07.836029	Añadida masivamente desde spell check	2025-11-05 18:12:07.836029	2025-11-05 18:12:07.836029
618	Core	core	other	1	1	2025-11-05 18:12:07.887365	Añadida masivamente desde spell check	2025-11-05 18:12:07.887365	2025-11-05 18:12:07.887365
619	MSCI	msci	other	1	1	2025-11-05 18:12:07.933812	Añadida masivamente desde spell check	2025-11-05 18:12:07.933812	2025-11-05 18:12:07.933812
621	UCITS	ucits	other	1	1	2025-11-05 18:12:08.024813	Añadida masivamente desde spell check	2025-11-05 18:12:08.024813	2025-11-05 18:12:08.024813
622	Ultrashort	ultrashort	other	1	1	2025-11-05 18:12:08.076015	Añadida masivamente desde spell check	2025-11-05 18:12:08.076015	2025-11-05 18:12:08.076015
624	SPDR	spdr	other	1	1	2025-11-05 18:12:08.166323	Añadida masivamente desde spell check	2025-11-05 18:12:08.166323	2025-11-05 18:12:08.166323
625	Barclays	barclays	other	1	1	2025-11-05 18:12:08.212664	Añadida masivamente desde spell check	2025-11-05 18:12:08.212664	2025-11-05 18:12:08.212664
626	Year	year	other	1	1	2025-11-05 18:12:08.258164	Añadida masivamente desde spell check	2025-11-05 18:12:08.258164	2025-11-05 18:12:08.258164
628	Xtrackers	xtrackers	other	1	1	2025-11-05 18:12:08.353281	Añadida masivamente desde spell check	2025-11-05 18:12:08.353281	2025-11-05 18:12:08.353281
629	Stoxx	stoxx	other	1	1	2025-11-05 18:12:08.40014	Añadida masivamente desde spell check	2025-11-05 18:12:08.40014	2025-11-05 18:12:08.40014
631	Trust	trust	other	1	1	2025-11-05 18:12:08.490538	Añadida masivamente desde spell check	2025-11-05 18:12:08.490538	2025-11-05 18:12:08.490538
632	Cybersecurity	cybersecurity	other	1	1	2025-11-05 18:12:08.534812	Añadida masivamente desde spell check	2025-11-05 18:12:08.534812	2025-11-05 18:12:08.534812
633	Robotics	robotics	other	1	1	2025-11-05 18:12:08.585353	Añadida masivamente desde spell check	2025-11-05 18:12:08.585353	2025-11-05 18:12:08.585353
634	Intelligence	intelligence	other	1	1	2025-11-05 18:12:08.629878	Añadida masivamente desde spell check	2025-11-05 18:12:08.629878	2025-11-05 18:12:08.629878
637	Health	health	other	1	1	2025-11-05 18:12:08.766085	Añadida masivamente desde spell check	2025-11-05 18:12:08.766085	2025-11-05 18:12:08.766085
638	Care	care	other	1	1	2025-11-05 18:12:08.819529	Añadida masivamente desde spell check	2025-11-05 18:12:08.819529	2025-11-05 18:12:08.819529
639	Bitcoin	bitcoin	other	1	1	2025-11-05 18:12:08.879326	Añadida masivamente desde spell check	2025-11-05 18:12:08.879326	2025-11-05 18:12:08.879326
641	Physical	physical	other	1	1	2025-11-05 18:12:08.970279	Añadida masivamente desde spell check	2025-11-05 18:12:08.970279	2025-11-05 18:12:08.970279
642	VanEck	vaneck	other	1	1	2025-11-05 18:12:09.014745	Añadida masivamente desde spell check	2025-11-05 18:12:09.014745	2025-11-05 18:12:09.014745
643	Ethereum	ethereum	other	1	1	2025-11-05 18:12:09.064147	Añadida masivamente desde spell check	2025-11-05 18:12:09.064147	2025-11-05 18:12:09.064147
644	WisdomTree	wisdomtree	other	1	1	2025-11-05 18:12:09.108927	Añadida masivamente desde spell check	2025-11-05 18:12:09.108927	2025-11-05 18:12:09.108927
646	Daily	daily	other	1	1	2025-11-05 18:12:09.201527	Añadida masivamente desde spell check	2025-11-05 18:12:09.201527	2025-11-05 18:12:09.201527
647	Leveraged	leveraged	other	1	1	2025-11-05 18:12:09.246578	Añadida masivamente desde spell check	2025-11-05 18:12:09.246578	2025-11-05 18:12:09.246578
648	Direxion	direxion	other	1	1	2025-11-05 18:12:09.291246	Añadida masivamente desde spell check	2025-11-05 18:12:09.291246	2025-11-05 18:12:09.291246
649	MSFT	msft	other	1	1	2025-11-05 18:12:09.334266	Añadida masivamente desde spell check	2025-11-05 18:12:09.334266	2025-11-05 18:12:09.334266
650	Shares	shares	other	1	1	2025-11-05 18:12:09.375529	Añadida masivamente desde spell check	2025-11-05 18:12:09.375529	2025-11-05 18:12:09.375529
651	Banks	banks	other	1	1	2025-11-05 18:12:09.417742	Añadida masivamente desde spell check	2025-11-05 18:12:09.417742	2025-11-05 18:12:09.417742
652	Gold	gold	other	1	1	2025-11-05 18:12:09.460722	Añadida masivamente desde spell check	2025-11-05 18:12:09.460722	2025-11-05 18:12:09.460722
653	Inverse	inverse	other	1	1	2025-11-05 18:12:09.506367	Añadida masivamente desde spell check	2025-11-05 18:12:09.506367	2025-11-05 18:12:09.506367
654	Brent	brent	other	1	1	2025-11-05 18:12:09.547705	Añadida masivamente desde spell check	2025-11-05 18:12:09.547705	2025-11-05 18:12:09.547705
655	Crude	crude	other	1	1	2025-11-05 18:12:09.593858	Añadida masivamente desde spell check	2025-11-05 18:12:09.593858	2025-11-05 18:12:09.593858
890	Sharp	sharp	other	3	1	2025-11-05 18:39:16.344714	Añadida masivamente desde spell check	2025-11-05 18:39:16.344714	2025-11-05 19:01:26.37511
657	Copper	copper	other	1	1	2025-11-05 18:12:09.678002	Añadida masivamente desde spell check	2025-11-05 18:12:09.678002	2025-11-05 18:12:09.678002
48	Fidelity	fidelity	other	5	1	2025-11-05 17:55:26.25692	Añadida masivamente desde spell check	2025-11-05 17:55:26.25692	2025-11-05 18:12:17.099751
310	Brands	brands	other	3	1	2025-11-05 18:11:30.775541	Añadida masivamente desde spell check	2025-11-05 18:11:30.775541	2025-11-05 18:12:17.749354
661	Smart	smart	other	2	1	2025-11-05 18:12:09.853532	Añadida masivamente desde spell check	2025-11-05 18:12:09.853532	2025-11-05 18:12:17.967387
636	Energy	energy	other	2	1	2025-11-05 18:12:08.720317	Añadida masivamente desde spell check	2025-11-05 18:12:08.720317	2025-11-05 18:12:18.033844
635	Small	small	other	2	1	2025-11-05 18:12:08.676974	Añadida masivamente desde spell check	2025-11-05 18:12:08.676974	2025-11-05 18:12:18.369536
256	Short	short	other	4	1	2025-11-05 18:11:27.921495	Añadida masivamente desde spell check	2025-11-05 18:11:27.921495	2025-11-05 18:12:26.334753
259	Duration	duration	other	3	1	2025-11-05 18:11:27.980202	Añadida masivamente desde spell check	2025-11-05 18:11:27.980202	2025-11-05 18:12:26.384544
300	Mason	mason	other	3	1	2025-11-05 18:11:30.428765	Añadida masivamente desde spell check	2025-11-05 18:11:30.428765	2025-11-05 18:12:27.019122
759	Inditex	inditex	other	1	1	2025-11-05 18:33:31.071877	Añadida masivamente desde spell check	2025-11-05 18:33:31.071877	2025-11-05 18:33:31.071877
762	Hermès	hermès	other	1	1	2025-11-05 18:33:31.249795	Añadida masivamente desde spell check	2025-11-05 18:33:31.249795	2025-11-05 18:33:31.249795
763	Alphabet	alphabet	other	1	1	2025-11-05 18:33:31.308799	Añadida masivamente desde spell check	2025-11-05 18:33:31.308799	2025-11-05 18:33:31.308799
764	Nvidia	nvidia	other	1	1	2025-11-05 18:33:31.370775	Añadida masivamente desde spell check	2025-11-05 18:33:31.370775	2025-11-05 18:33:31.370775
765	EuroStoxx	eurostoxx	other	1	1	2025-11-05 18:33:31.424013	Añadida masivamente desde spell check	2025-11-05 18:33:31.424013	2025-11-05 18:33:31.424013
766	Frankfurt	frankfurt	other	1	1	2025-11-05 18:33:31.475665	Añadida masivamente desde spell check	2025-11-05 18:33:31.475665	2025-11-05 18:33:31.475665
767	NYSE	nyse	other	1	1	2025-11-05 18:33:31.53202	Añadida masivamente desde spell check	2025-11-05 18:33:31.53202	2025-11-05 18:33:31.53202
768	sobreponderada	sobreponderada	other	1	1	2025-11-05 18:33:31.589917	Añadida masivamente desde spell check	2025-11-05 18:33:31.589917	2025-11-05 18:33:31.589917
769	ratios	ratios	other	1	1	2025-11-05 18:33:31.6443	Añadida masivamente desde spell check	2025-11-05 18:33:31.6443	2025-11-05 18:33:31.6443
780	Merlin	merlin	other	1	1	2025-11-05 18:33:32.369816	Añadida masivamente desde spell check	2025-11-05 18:33:32.369816	2025-11-05 18:33:32.369816
781	Properties	properties	other	1	1	2025-11-05 18:33:32.456951	Añadida masivamente desde spell check	2025-11-05 18:33:32.456951	2025-11-05 18:33:32.456951
782	Javier	javier	other	1	1	2025-11-05 18:33:32.51309	Añadida masivamente desde spell check	2025-11-05 18:33:32.51309	2025-11-05 18:33:32.51309
783	Díaz	díaz	other	1	1	2025-11-05 18:33:32.567943	Añadida masivamente desde spell check	2025-11-05 18:33:32.567943	2025-11-05 18:33:32.567943
784	Fráncfort	fráncfort	other	1	1	2025-11-05 18:33:32.617106	Añadida masivamente desde spell check	2025-11-05 18:33:32.617106	2025-11-05 18:33:32.617106
785	Londres	londres	other	1	1	2025-11-05 18:33:32.662312	Añadida masivamente desde spell check	2025-11-05 18:33:32.662312	2025-11-05 18:33:32.662312
786	Ámsterdam	ámsterdam	other	1	1	2025-11-05 18:33:32.711555	Añadida masivamente desde spell check	2025-11-05 18:33:32.711555	2025-11-05 18:33:32.711555
787	Helsinki	helsinki	other	1	1	2025-11-05 18:33:32.763277	Añadida masivamente desde spell check	2025-11-05 18:33:32.763277	2025-11-05 18:33:32.763277
788	Estocolmo	estocolmo	other	1	1	2025-11-05 18:33:32.813411	Añadida masivamente desde spell check	2025-11-05 18:33:32.813411	2025-11-05 18:33:32.813411
771	Aspy	aspy	other	3	1	2025-11-05 18:33:31.779437	Añadida masivamente desde spell check	2025-11-05 18:33:31.779437	2025-11-05 18:36:40.288632
772	Services	services	other	3	1	2025-11-05 18:33:31.847622	Añadida masivamente desde spell check	2025-11-05 18:33:31.847622	2025-11-05 18:36:40.340057
773	Pablo	pablo	other	3	1	2025-11-05 18:33:31.914903	Añadida masivamente desde spell check	2025-11-05 18:33:31.914903	2025-11-05 18:36:40.40749
774	Fernández	fernández	other	3	1	2025-11-05 18:33:31.985327	Añadida masivamente desde spell check	2025-11-05 18:33:31.985327	2025-11-05 18:36:40.459696
775	Mosteyrín	mosteyrín	other	3	1	2025-11-05 18:33:32.060402	Añadida masivamente desde spell check	2025-11-05 18:33:32.060402	2025-11-05 18:36:40.508055
776	Ivan	ivan	other	3	1	2025-11-05 18:33:32.122868	Añadida masivamente desde spell check	2025-11-05 18:33:32.122868	2025-11-05 18:36:40.554702
777	Aena	aena	other	3	1	2025-11-05 18:33:32.187223	Añadida masivamente desde spell check	2025-11-05 18:33:32.187223	2025-11-05 18:36:40.607176
778	Pérez	pérez	other	3	1	2025-11-05 18:33:32.250446	Añadida masivamente desde spell check	2025-11-05 18:33:32.250446	2025-11-05 18:36:40.65191
789	Lisboa	lisboa	other	1	1	2025-11-05 18:33:32.861966	Añadida masivamente desde spell check	2025-11-05 18:33:32.861966	2025-11-05 18:33:32.861966
790	Amex	amex	other	1	1	2025-11-05 18:33:32.91533	Añadida masivamente desde spell check	2025-11-05 18:33:32.91533	2025-11-05 18:33:32.91533
791	Tokio	tokio	other	1	1	2025-11-05 18:33:32.964842	Añadida masivamente desde spell check	2025-11-05 18:33:32.964842	2025-11-05 18:33:32.964842
792	plantéate	plantéate	other	1	1	2025-11-05 18:33:33.012936	Añadida masivamente desde spell check	2025-11-05 18:33:33.012936	2025-11-05 18:33:33.012936
794	Eurex	eurex	other	1	1	2025-11-05 18:36:11.726753	Añadida masivamente desde spell check	2025-11-05 18:36:11.726753	2025-11-05 18:36:11.726753
795	Euronext	euronext	other	1	1	2025-11-05 18:36:11.788241	Añadida masivamente desde spell check	2025-11-05 18:36:11.788241	2025-11-05 18:36:11.788241
796	EEUU	eeuu	other	1	1	2025-11-05 18:36:11.846024	Añadida masivamente desde spell check	2025-11-05 18:36:11.846024	2025-11-05 18:36:11.846024
797	NYMEX	nymex	other	1	1	2025-11-05 18:36:11.89454	Añadida masivamente desde spell check	2025-11-05 18:36:11.89454	2025-11-05 18:36:11.89454
798	COMEX	comex	other	1	1	2025-11-05 18:36:11.941067	Añadida masivamente desde spell check	2025-11-05 18:36:11.941067	2025-11-05 18:36:11.941067
799	CBOT	cbot	other	1	1	2025-11-05 18:36:11.992022	Añadida masivamente desde spell check	2025-11-05 18:36:11.992022	2025-11-05 18:36:11.992022
800	CBOE	cboe	other	1	1	2025-11-05 18:36:12.040704	Añadida masivamente desde spell check	2025-11-05 18:36:12.040704	2025-11-05 18:36:12.040704
801	Streaming	streaming	other	1	1	2025-11-05 18:36:12.090941	Añadida masivamente desde spell check	2025-11-05 18:36:12.090941	2025-11-05 18:36:12.090941
802	MINI	mini	other	1	1	2025-11-05 18:36:12.146601	Añadida masivamente desde spell check	2025-11-05 18:36:12.146601	2025-11-05 18:36:12.146601
803	Asia	asia	other	1	1	2025-11-05 18:36:12.191655	Añadida masivamente desde spell check	2025-11-05 18:36:12.191655	2025-11-05 18:36:12.191655
804	Benefíciate	benefíciate	other	1	1	2025-11-05 18:36:12.239076	Añadida masivamente desde spell check	2025-11-05 18:36:12.239076	2025-11-05 18:36:12.239076
877	Jesús	jesús	other	3	1	2025-11-05 18:37:09.892144	Añadida masivamente desde spell check	2025-11-05 18:37:09.892144	2025-11-05 18:58:32.872837
825	forwards	forwards	other	1	1	2025-11-05 18:36:13.412341	Añadida masivamente desde spell check	2025-11-05 18:36:13.412341	2025-11-05 18:36:13.412341
826	contratables	contratables	other	1	1	2025-11-05 18:36:13.48068	Añadida masivamente desde spell check	2025-11-05 18:36:13.48068	2025-11-05 18:36:13.48068
827	Brókers	brókers	other	1	1	2025-11-05 18:36:13.56092	Añadida masivamente desde spell check	2025-11-05 18:36:13.56092	2025-11-05 18:36:13.56092
823	Call	call	other	2	1	2025-11-05 18:36:13.282773	Añadida masivamente desde spell check	2025-11-05 18:36:13.282773	2025-11-05 18:36:39.098193
829	Best	best	other	1	1	2025-11-05 18:36:39.164394	Añadida masivamente desde spell check	2025-11-05 18:36:39.164394	2025-11-05 18:36:39.164394
830	Inline	inline	other	1	1	2025-11-05 18:36:39.234084	Añadida masivamente desde spell check	2025-11-05 18:36:39.234084	2025-11-05 18:36:39.234084
831	Stayhigh	stayhigh	other	1	1	2025-11-05 18:36:39.289818	Añadida masivamente desde spell check	2025-11-05 18:36:39.289818	2025-11-05 18:36:39.289818
832	Staylow	staylow	other	1	1	2025-11-05 18:36:39.338502	Añadida masivamente desde spell check	2025-11-05 18:36:39.338502	2025-11-05 18:36:39.338502
833	Multi	multi	other	1	1	2025-11-05 18:36:39.38738	Añadida masivamente desde spell check	2025-11-05 18:36:39.38738	2025-11-05 18:36:39.38738
834	eurodólar	eurodólar	other	1	1	2025-11-05 18:36:39.431652	Añadida masivamente desde spell check	2025-11-05 18:36:39.431652	2025-11-05 18:36:39.431652
835	Trackers	trackers	other	1	1	2025-11-05 18:36:39.485444	Añadida masivamente desde spell check	2025-11-05 18:36:39.485444	2025-11-05 18:36:39.485444
836	Unlimited	unlimited	other	1	1	2025-11-05 18:36:39.534249	Añadida masivamente desde spell check	2025-11-05 18:36:39.534249	2025-11-05 18:36:39.534249
837	Certificated	certificated	other	1	1	2025-11-05 18:36:39.594416	Añadida masivamente desde spell check	2025-11-05 18:36:39.594416	2025-11-05 18:36:39.594416
838	tracker	tracker	other	1	1	2025-11-05 18:36:39.656924	Añadida masivamente desde spell check	2025-11-05 18:36:39.656924	2025-11-05 18:36:39.656924
805	Société	société	other	2	1	2025-11-05 18:36:12.284711	Añadida masivamente desde spell check	2025-11-05 18:36:12.284711	2025-11-05 18:36:39.719914
806	Générale	générale	other	2	1	2025-11-05 18:36:12.346408	Añadida masivamente desde spell check	2025-11-05 18:36:12.346408	2025-11-05 18:36:39.78484
824	CFDs	cfds	other	2	1	2025-11-05 18:36:13.347651	Añadida masivamente desde spell check	2025-11-05 18:36:13.347651	2025-11-05 18:36:39.833803
807	xRolling	xrolling	other	2	1	2025-11-05 18:36:12.407749	Añadida masivamente desde spell check	2025-11-05 18:36:12.407749	2025-11-05 18:36:39.887415
793	MEFF	meff	other	2	1	2025-11-05 18:36:11.660543	Añadida masivamente desde spell check	2025-11-05 18:36:11.660543	2025-11-05 18:36:39.94723
808	Faes	faes	other	2	1	2025-11-05 18:36:12.47086	Añadida masivamente desde spell check	2025-11-05 18:36:12.47086	2025-11-05 18:36:39.993709
809	Farma	farma	other	2	1	2025-11-05 18:36:12.51926	Añadida masivamente desde spell check	2025-11-05 18:36:12.51926	2025-11-05 18:36:40.038134
810	Reinvirtiendo	reinvirtiendo	other	2	1	2025-11-05 18:36:12.563887	Añadida masivamente desde spell check	2025-11-05 18:36:12.563887	2025-11-05 18:36:40.090409
811	Álvaro	álvaro	other	2	1	2025-11-05 18:36:12.611874	Añadida masivamente desde spell check	2025-11-05 18:36:12.611874	2025-11-05 18:36:40.136876
812	Arístegui	arístegui	other	2	1	2025-11-05 18:36:12.658579	Añadida masivamente desde spell check	2025-11-05 18:36:12.658579	2025-11-05 18:36:40.191026
770	Atrys	atrys	other	3	1	2025-11-05 18:33:31.709611	Añadida masivamente desde spell check	2025-11-05 18:33:31.709611	2025-11-05 18:36:40.241527
779	Llamazares	llamazares	other	3	1	2025-11-05 18:33:32.304159	Añadida masivamente desde spell check	2025-11-05 18:33:32.304159	2025-11-05 18:36:40.697882
859	RCBs	rcbs	other	1	1	2025-11-05 18:36:40.743939	Añadida masivamente desde spell check	2025-11-05 18:36:40.743939	2025-11-05 18:36:40.743939
860	rally	rally	other	1	1	2025-11-05 18:37:09.047917	Añadida masivamente desde spell check	2025-11-05 18:37:09.047917	2025-11-05 18:37:09.047917
861	Alberto	alberto	other	1	1	2025-11-05 18:37:09.1039	Añadida masivamente desde spell check	2025-11-05 18:37:09.1039	2025-11-05 18:37:09.1039
862	Espelosín	espelosín	other	1	1	2025-11-05 18:37:09.167594	Añadida masivamente desde spell check	2025-11-05 18:37:09.167594	2025-11-05 18:37:09.167594
863	Alejandro	alejandro	other	1	1	2025-11-05 18:37:09.225697	Añadida masivamente desde spell check	2025-11-05 18:37:09.225697	2025-11-05 18:37:09.225697
864	Varela	varela	other	1	1	2025-11-05 18:37:09.270942	Añadida masivamente desde spell check	2025-11-05 18:37:09.270942	2025-11-05 18:37:09.270942
865	Sobreira	sobreira	other	1	1	2025-11-05 18:37:09.31548	Añadida masivamente desde spell check	2025-11-05 18:37:09.31548	2025-11-05 18:37:09.31548
866	Conesa	conesa	other	1	1	2025-11-05 18:37:09.360939	Añadida masivamente desde spell check	2025-11-05 18:37:09.360939	2025-11-05 18:37:09.360939
867	Antonio	antonio	other	1	1	2025-11-05 18:37:09.411396	Añadida masivamente desde spell check	2025-11-05 18:37:09.411396	2025-11-05 18:37:09.411396
868	Sanz	sanz	other	1	1	2025-11-05 18:37:09.458528	Añadida masivamente desde spell check	2025-11-05 18:37:09.458528	2025-11-05 18:37:09.458528
870	Laorga	laorga	other	1	1	2025-11-05 18:37:09.55456	Añadida masivamente desde spell check	2025-11-05 18:37:09.55456	2025-11-05 18:37:09.55456
871	Celso	celso	other	1	1	2025-11-05 18:37:09.609226	Añadida masivamente desde spell check	2025-11-05 18:37:09.609226	2025-11-05 18:37:09.609226
872	David	david	other	1	1	2025-11-05 18:37:09.656794	Añadida masivamente desde spell check	2025-11-05 18:37:09.656794	2025-11-05 18:37:09.656794
873	Jareño	jareño	other	1	1	2025-11-05 18:37:09.704627	Añadida masivamente desde spell check	2025-11-05 18:37:09.704627	2025-11-05 18:37:09.704627
874	Dptos	dptos	other	1	1	2025-11-05 18:37:09.748685	Añadida masivamente desde spell check	2025-11-05 18:37:09.748685	2025-11-05 18:37:09.748685
875	Elena	elena	other	1	1	2025-11-05 18:37:09.797107	Añadida masivamente desde spell check	2025-11-05 18:37:09.797107	2025-11-05 18:37:09.797107
876	Ignacio	ignacio	other	1	1	2025-11-05 18:37:09.845315	Añadida masivamente desde spell check	2025-11-05 18:37:09.845315	2025-11-05 18:37:09.845315
878	Ureta	ureta	other	1	1	2025-11-05 18:37:09.937947	Añadida masivamente desde spell check	2025-11-05 18:37:09.937947	2025-11-05 18:37:09.937947
879	Garcia	garcia	other	1	1	2025-11-05 18:37:09.982586	Añadida masivamente desde spell check	2025-11-05 18:37:09.982586	2025-11-05 18:37:09.982586
880	Natalia	natalia	other	1	1	2025-11-05 18:37:10.027495	Añadida masivamente desde spell check	2025-11-05 18:37:10.027495	2025-11-05 18:37:10.027495
881	Aguirre	aguirre	other	1	1	2025-11-05 18:37:10.082849	Añadida masivamente desde spell check	2025-11-05 18:37:10.082849	2025-11-05 18:37:10.082849
882	Sampedro	sampedro	other	1	1	2025-11-05 18:37:10.130305	Añadida masivamente desde spell check	2025-11-05 18:37:10.130305	2025-11-05 18:37:10.130305
883	Toni	toni	other	1	1	2025-11-05 18:37:10.17916	Añadida masivamente desde spell check	2025-11-05 18:37:10.17916	2025-11-05 18:37:10.17916
884	Andrés	andrés	other	1	1	2025-11-05 18:37:10.23099	Añadida masivamente desde spell check	2025-11-05 18:37:10.23099	2025-11-05 18:37:10.23099
885	Nikkei	nikkei	other	1	1	2025-11-05 18:37:10.279274	Añadida masivamente desde spell check	2025-11-05 18:37:10.279274	2025-11-05 18:37:10.279274
886	Vadis	vadis	other	1	1	2025-11-05 18:37:10.331333	Añadida masivamente desde spell check	2025-11-05 18:37:10.331333	2025-11-05 18:37:10.331333
888	Cash	cash	other	2	1	2025-11-05 18:39:01.580002	Añadida desde spell check	2025-11-05 18:39:01.580002	2025-11-05 18:55:04.625827
907	Tresorerie	tresorerie	other	1	1	2025-11-05 18:55:07.060428	Añadida desde spell check	2025-11-05 18:55:07.060428	2025-11-05 18:55:07.060428
897	Imgp	imgp	other	2	1	2025-11-05 18:39:40.529844	Añadida desde spell check	2025-11-05 18:39:40.529844	2025-11-05 18:55:28.935933
898	Invf	invf	other	2	1	2025-11-05 18:39:45.235421	Añadida desde spell check	2025-11-05 18:39:45.235421	2025-11-05 18:55:31.17925
899	Conviction	conviction	other	2	1	2025-11-05 18:39:47.712912	Añadida desde spell check	2025-11-05 18:39:47.712912	2025-11-05 18:56:39.444877
904	ROTHSCHILD	rothschild	other	2	1	2025-11-05 18:40:09.975691	Añadida desde spell check	2025-11-05 18:40:09.975691	2025-11-05 18:56:42.035386
903	Dpam	dpam	other	2	1	2025-11-05 18:40:05.092035	Añadida desde spell check	2025-11-05 18:40:05.092035	2025-11-05 18:56:47.273803
901	Govt	govt	other	2	1	2025-11-05 18:39:59.410449	Añadida desde spell check	2025-11-05 18:39:59.410449	2025-11-05 18:56:50.894239
905	Axawf	axawf	other	2	1	2025-11-05 18:40:14.037676	Añadida desde spell check	2025-11-05 18:40:14.037676	2025-11-05 18:56:52.72044
900	Tikehau	tikehau	other	2	1	2025-11-05 18:39:56.187164	Añadida desde spell check	2025-11-05 18:39:56.187164	2025-11-05 18:56:54.573941
925	Sust	sust	other	1	1	2025-11-05 18:56:56.114236	Añadida desde spell check	2025-11-05 18:56:56.114236	2025-11-05 18:56:56.114236
926	Shrt	shrt	other	1	1	2025-11-05 18:56:58.009259	Añadida desde spell check	2025-11-05 18:56:58.009259	2025-11-05 18:56:58.009259
927	Durem	durem	other	1	1	2025-11-05 18:57:01.065044	Añadida desde spell check	2025-11-05 18:57:01.065044	2025-11-05 18:57:01.065044
928	Dbteur	dbteur	other	1	1	2025-11-05 18:57:03.472376	Añadida desde spell check	2025-11-05 18:57:03.472376	2025-11-05 18:57:03.472376
929	High	high	other	1	1	2025-11-05 18:57:05.816164	Añadida desde spell check	2025-11-05 18:57:05.816164	2025-11-05 18:57:05.816164
930	Yield	yield	other	1	1	2025-11-05 18:57:08.503056	Añadida desde spell check	2025-11-05 18:57:08.503056	2025-11-05 18:57:08.503056
931	Solution	solution	other	1	1	2025-11-05 18:57:14.13626	Añadida desde spell check	2025-11-05 18:57:14.13626	2025-11-05 18:57:14.13626
932	Fórmate	fórmate	other	2	1	2025-11-05 18:57:36.441077	Añadida masivamente desde spell check	2025-11-05 18:57:36.441077	2025-11-05 18:58:29.23779
933	Podcasts	podcasts	other	2	1	2025-11-05 18:57:36.525583	Añadida masivamente desde spell check	2025-11-05 18:57:36.525583	2025-11-05 18:58:29.42408
934	desinvertir	desinvertir	other	2	1	2025-11-05 18:57:36.605506	Añadida masivamente desde spell check	2025-11-05 18:57:36.605506	2025-11-05 18:58:29.614893
935	Instagram	instagram	other	2	1	2025-11-05 18:57:36.680212	Añadida masivamente desde spell check	2025-11-05 18:57:36.680212	2025-11-05 18:58:29.812783
936	LinkedIn	linkedin	other	2	1	2025-11-05 18:57:36.768592	Añadida masivamente desde spell check	2025-11-05 18:57:36.768592	2025-11-05 18:58:30.035653
937	Ivoox	ivoox	other	2	1	2025-11-05 18:57:36.864545	Añadida masivamente desde spell check	2025-11-05 18:57:36.864545	2025-11-05 18:58:30.233235
938	Spotify	spotify	other	2	1	2025-11-05 18:57:36.959245	Añadida masivamente desde spell check	2025-11-05 18:57:36.959245	2025-11-05 18:58:30.448437
939	Eduardo	eduardo	other	2	1	2025-11-05 18:57:37.037947	Añadida masivamente desde spell check	2025-11-05 18:57:37.037947	2025-11-05 18:58:30.677634
940	Faus	faus	other	2	1	2025-11-05 18:57:37.134404	Añadida masivamente desde spell check	2025-11-05 18:57:37.134404	2025-11-05 18:58:30.878065
941	Domínguez	domínguez	other	2	1	2025-11-05 18:57:37.205386	Añadida masivamente desde spell check	2025-11-05 18:57:37.205386	2025-11-05 18:58:31.113933
942	Youtube	youtube	other	2	1	2025-11-05 18:57:37.280257	Añadida masivamente desde spell check	2025-11-05 18:57:37.280257	2025-11-05 18:58:31.356957
943	Twitter	twitter	other	2	1	2025-11-05 18:57:37.350837	Añadida masivamente desde spell check	2025-11-05 18:57:37.350837	2025-11-05 18:58:31.527485
944	Facebook	facebook	other	2	1	2025-11-05 18:57:37.41764	Añadida masivamente desde spell check	2025-11-05 18:57:37.41764	2025-11-05 18:58:31.729492
869	Carlos	carlos	other	3	1	2025-11-05 18:37:09.507835	Añadida masivamente desde spell check	2025-11-05 18:37:09.507835	2025-11-05 18:58:31.88562
946	Sofía	sofía	other	2	1	2025-11-05 18:57:37.559083	Añadida masivamente desde spell check	2025-11-05 18:57:37.559083	2025-11-05 18:58:32.065562
947	Cisneros	cisneros	other	2	1	2025-11-05 18:57:37.634229	Añadida masivamente desde spell check	2025-11-05 18:57:37.634229	2025-11-05 18:58:32.269379
948	Society	society	other	2	1	2025-11-05 18:57:37.718241	Añadida masivamente desde spell check	2025-11-05 18:57:37.718241	2025-11-05 18:58:32.477073
949	Alicia	alicia	other	2	1	2025-11-05 18:57:37.807157	Añadida masivamente desde spell check	2025-11-05 18:57:37.807157	2025-11-05 18:58:32.660333
951	Aparicio	aparicio	other	2	1	2025-11-05 18:57:37.948302	Añadida masivamente desde spell check	2025-11-05 18:57:37.948302	2025-11-05 18:58:33.042402
972	descorrelacionada	descorrelacionada	other	1	1	2025-11-05 19:01:24.111116	Añadida masivamente desde spell check	2025-11-05 19:01:24.111116	2025-11-05 19:01:24.111116
973	descorrelacionados	descorrelacionados	other	1	1	2025-11-05 19:01:24.551532	Añadida masivamente desde spell check	2025-11-05 19:01:24.551532	2025-11-05 19:01:24.551532
974	Equinox	equinox	other	1	1	2025-11-05 19:01:25.030445	Añadida masivamente desde spell check	2025-11-05 19:01:25.030445	2025-11-05 19:01:25.030445
975	Allocation	allocation	other	1	1	2025-11-05 19:01:25.674555	Añadida masivamente desde spell check	2025-11-05 19:01:25.674555	2025-11-05 19:01:25.674555
889	Volat	volat	other	3	1	2025-11-05 18:39:13.30169	Añadida masivamente desde spell check	2025-11-05 18:39:13.30169	2025-11-05 19:01:26.045491
892	Reemb	reemb	other	3	1	2025-11-05 18:39:25.542795	Añadida masivamente desde spell check	2025-11-05 18:39:25.542795	2025-11-05 19:01:27.080084
893	Susc	susc	other	3	1	2025-11-05 18:39:29.059217	Añadida masivamente desde spell check	2025-11-05 18:39:29.059217	2025-11-05 19:01:27.439845
894	Sharpe	sharpe	other	3	1	2025-11-05 18:39:33.543285	Añadida masivamente desde spell check	2025-11-05 18:39:33.543285	2025-11-05 19:01:27.758993
895	William	william	other	3	1	2025-11-05 18:39:36.039467	Añadida masivamente desde spell check	2025-11-05 18:39:36.039467	2025-11-05 19:01:28.145461
896	anualizados	anualizados	other	3	1	2025-11-05 18:39:38.597203	Añadida masivamente desde spell check	2025-11-05 18:39:38.597203	2025-11-05 19:01:28.516329
984	Alpha	alpha	other	1	1	2025-11-05 19:01:28.799853	Añadida masivamente desde spell check	2025-11-05 19:01:28.799853	2025-11-05 19:01:28.799853
902	Bonds	bonds	other	3	1	2025-11-05 18:40:02.037472	Añadida masivamente desde spell check	2025-11-05 18:40:02.037472	2025-11-05 19:01:29.380573
986	Jupitermerian	jupitermerian	other	1	1	2025-11-05 19:01:29.863231	Añadida masivamente desde spell check	2025-11-05 19:01:29.863231	2025-11-05 19:01:29.863231
987	Absolute	absolute	other	1	1	2025-11-05 19:01:30.359547	Añadida masivamente desde spell check	2025-11-05 19:01:30.359547	2025-11-05 19:01:30.359547
988	Return	return	other	1	1	2025-11-05 19:01:30.767486	Añadida masivamente desde spell check	2025-11-05 19:01:30.767486	2025-11-05 19:01:30.767486
989	Hedged	hedged	other	1	1	2025-11-05 19:01:31.160772	Añadida masivamente desde spell check	2025-11-05 19:01:31.160772	2025-11-05 19:01:31.160772
990	desa	desa	other	1	1	2025-11-05 19:01:31.55151	Añadida masivamente desde spell check	2025-11-05 19:01:31.55151	2025-11-05 19:01:31.55151
992	recíbela	recíbela	other	9	1	2025-11-05 19:04:20.159339	Importada masivamente desde errores de spell check (freq: 9)	2025-11-05 19:04:20.159339	2025-11-05 19:04:20.159339
993	liquidativo	liquidativo	other	7	1	2025-11-05 19:04:20.322104	Importada masivamente desde errores de spell check (freq: 7)	2025-11-05 19:04:20.322104	2025-11-05 19:04:20.322104
996	BBVA	bbva	other	5	1	2025-11-05 19:04:20.6232	Importada masivamente desde errores de spell check (freq: 5)	2025-11-05 19:04:20.6232	2025-11-05 19:04:20.6232
999	rentabilizado	rentabilizado	other	4	1	2025-11-05 19:04:21.001143	Importada masivamente desde errores de spell check (freq: 4)	2025-11-05 19:04:21.001143	2025-11-05 19:04:21.001143
1000	Foncuenta	foncuenta	other	4	1	2025-11-05 19:04:21.198787	Importada masivamente desde errores de spell check (freq: 4)	2025-11-05 19:04:21.198787	2025-11-05 19:04:21.198787
1001	Dedalo	dedalo	other	4	1	2025-11-05 19:04:21.275708	Importada masivamente desde errores de spell check (freq: 4)	2025-11-05 19:04:21.275708	2025-11-05 19:04:21.275708
1003	Exchange	exchange	other	4	1	2025-11-05 19:04:21.471985	Importada masivamente desde errores de spell check (freq: 4)	2025-11-05 19:04:21.471985	2025-11-05 19:04:21.471985
1004	tablet	tablet	other	4	1	2025-11-05 19:04:21.595394	Importada masivamente desde errores de spell check (freq: 4)	2025-11-05 19:04:21.595394	2025-11-05 19:04:21.595394
1005	diferimiento	diferimiento	other	3	1	2025-11-05 19:04:21.674384	Importada masivamente desde errores de spell check (freq: 3)	2025-11-05 19:04:21.674384	2025-11-05 19:04:21.674384
1006	multititular	multititular	other	3	1	2025-11-05 19:04:21.890466	Importada masivamente desde errores de spell check (freq: 3)	2025-11-05 19:04:21.890466	2025-11-05 19:04:21.890466
1007	Enagás	enagás	other	3	1	2025-11-05 19:04:22.011589	Importada masivamente desde errores de spell check (freq: 3)	2025-11-05 19:04:22.011589	2025-11-05 19:04:22.011589
1008	Almirall	almirall	other	3	1	2025-11-05 19:04:22.122761	Importada masivamente desde errores de spell check (freq: 3)	2025-11-05 19:04:22.122761	2025-11-05 19:04:22.122761
1009	Fondtesoro	fondtesoro	other	3	1	2025-11-05 19:04:22.246046	Importada masivamente desde errores de spell check (freq: 3)	2025-11-05 19:04:22.246046	2025-11-05 19:04:22.246046
1011	blockchain	blockchain	other	3	1	2025-11-05 19:04:22.474376	Importada masivamente desde errores de spell check (freq: 3)	2025-11-05 19:04:22.474376	2025-11-05 19:04:22.474376
1012	multidispositivo	multidispositivo	other	3	1	2025-11-05 19:04:22.56027	Importada masivamente desde errores de spell check (freq: 3)	2025-11-05 19:04:22.56027	2025-11-05 19:04:22.56027
1014	MIFID	mifid	other	3	1	2025-11-05 19:04:22.865305	Importada masivamente desde errores de spell check (freq: 3)	2025-11-05 19:04:22.865305	2025-11-05 19:04:22.865305
1016	wallet	wallet	other	3	1	2025-11-05 19:04:23.026101	Importada masivamente desde errores de spell check (freq: 3)	2025-11-05 19:04:23.026101	2025-11-05 19:04:23.026101
1017	megatendencia	megatendencia	other	3	1	2025-11-05 19:04:23.123161	Importada masivamente desde errores de spell check (freq: 3)	2025-11-05 19:04:23.123161	2025-11-05 19:04:23.123161
1018	rollover	rollover	other	3	1	2025-11-05 19:04:23.22612	Importada masivamente desde errores de spell check (freq: 3)	2025-11-05 19:04:23.22612	2025-11-05 19:04:23.22612
1019	Chile	chile	other	3	1	2025-11-05 19:04:23.301318	Importada masivamente desde errores de spell check (freq: 3)	2025-11-05 19:04:23.301318	2025-11-05 19:04:23.301318
1020	Perú	perú	other	3	1	2025-11-05 19:04:23.371001	Importada masivamente desde errores de spell check (freq: 3)	2025-11-05 19:04:23.371001	2025-11-05 19:04:23.371001
1021	Colombia	colombia	other	3	1	2025-11-05 19:04:23.437173	Importada masivamente desde errores de spell check (freq: 3)	2025-11-05 19:04:23.437173	2025-11-05 19:04:23.437173
1022	FAQs	faqs	other	3	1	2025-11-05 19:04:23.51109	Importada masivamente desde errores de spell check (freq: 3)	2025-11-05 19:04:23.51109	2025-11-05 19:04:23.51109
1023	LOPD	lopd	other	3	1	2025-11-05 19:04:23.615425	Importada masivamente desde errores de spell check (freq: 3)	2025-11-05 19:04:23.615425	2025-11-05 19:04:23.615425
1024	Pruébalo	pruébalo	other	3	1	2025-11-05 19:04:23.704786	Importada masivamente desde errores de spell check (freq: 3)	2025-11-05 19:04:23.704786	2025-11-05 19:04:23.704786
1025	invesor	invesor	other	2	1	2025-11-05 19:04:23.763918	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:23.763918	2025-11-05 19:04:23.763918
1026	Tecnologia	tecnologia	other	2	1	2025-11-05 19:04:23.834438	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:23.834438	2025-11-05 19:04:23.834438
1028	Cirsa	cirsa	other	2	1	2025-11-05 19:04:24.013905	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:24.013905	2025-11-05 19:04:24.013905
1029	guidance	guidance	other	2	1	2025-11-05 19:04:24.096282	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:24.096282	2025-11-05 19:04:24.096282
1030	Rovi	rovi	other	2	1	2025-11-05 19:04:24.256464	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:24.256464	2025-11-05 19:04:24.256464
1031	Sacyr	sacyr	other	2	1	2025-11-05 19:04:24.560754	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:24.560754	2025-11-05 19:04:24.560754
1032	American	american	other	2	1	2025-11-05 19:04:24.718103	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:24.718103	2025-11-05 19:04:24.718103
1033	Metavalor	metavalor	other	2	1	2025-11-05 19:04:24.783785	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:24.783785	2025-11-05 19:04:24.783785
1034	Nexus	nexus	other	2	1	2025-11-05 19:04:24.970294	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:24.970294	2025-11-05 19:04:24.970294
1035	ESMA	esma	other	2	1	2025-11-05 19:04:25.08969	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:25.08969	2025-11-05 19:04:25.08969
1036	Societé	societé	other	2	1	2025-11-05 19:04:25.219091	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:25.219091	2025-11-05 19:04:25.219091
1037	REDEIA	redeia	other	2	1	2025-11-05 19:04:25.423119	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:25.423119	2025-11-05 19:04:25.423119
1038	stablecoins	stablecoins	other	2	1	2025-11-05 19:04:25.528975	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:25.528975	2025-11-05 19:04:25.528975
1040	Powell	powell	other	2	1	2025-11-05 19:04:25.874201	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:25.874201	2025-11-05 19:04:25.874201
997	stop	stop	other	7	1	2025-11-05 19:04:20.707873	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:20.707873	2025-11-05 19:04:26.026868
1013	loss	loss	other	5	1	2025-11-05 19:04:22.637865	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:22.637865	2025-11-05 19:04:26.211604
1043	Descárgate	descárgate	other	2	1	2025-11-05 19:04:26.296268	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:26.296268	2025-11-05 19:04:26.296268
1044	Webinar	webinar	other	2	1	2025-11-05 19:04:26.366876	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:26.366876	2025-11-05 19:04:26.366876
1010	Epsv	epsv	other	5	1	2025-11-05 19:04:22.300645	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:22.300645	2025-11-05 19:04:27.221509
991	Easy	easy	other	32	1	2025-11-05 19:04:19.967517	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:19.967517	2025-11-05 19:04:40.183339
994	Bizum	bizum	other	7	1	2025-11-05 19:04:20.426746	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:20.426746	2025-11-05 19:04:43.910346
1045	webinars	webinars	other	3	1	2025-11-05 19:04:26.457653	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:26.457653	2025-11-05 19:04:44.764776
995	Slow	slow	other	7	1	2025-11-05 19:04:20.518609	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:20.518609	2025-11-05 19:04:45.929033
998	Finance	finance	other	7	1	2025-11-05 19:04:20.879151	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:20.879151	2025-11-05 19:04:46.041612
1047	POLITICA	politica	other	2	1	2025-11-05 19:04:26.656333	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:26.656333	2025-11-05 19:04:26.656333
1048	Android	android	other	2	1	2025-11-05 19:04:26.747874	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:26.747874	2025-11-05 19:04:26.747874
1049	Wealth	wealth	other	2	1	2025-11-05 19:04:26.816207	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:26.816207	2025-11-05 19:04:26.816207
1051	Foreign	foreign	other	2	1	2025-11-05 19:04:26.963805	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:26.963805	2025-11-05 19:04:26.963805
1052	reinvertir	reinvertir	other	2	1	2025-11-05 19:04:27.041177	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:27.041177	2025-11-05 19:04:27.041177
1053	desgravarte	desgravarte	other	2	1	2025-11-05 19:04:27.149693	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:27.149693	2025-11-05 19:04:27.149693
1057	Estratègies	estratègies	other	2	1	2025-11-05 19:04:27.643997	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:27.643997	2025-11-05 19:04:27.643997
1058	Anàlisi	anàlisi	other	2	1	2025-11-05 19:04:27.718189	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:27.718189	2025-11-05 19:04:27.718189
1059	Tècnic	tècnic	other	2	1	2025-11-05 19:04:27.788612	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:27.788612	2025-11-05 19:04:27.788612
1060	Quantitatius	quantitatius	other	2	1	2025-11-05 19:04:27.903406	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:27.903406	2025-11-05 19:04:27.903406
1061	Numèrics	numèrics	other	2	1	2025-11-05 19:04:27.982995	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:27.982995	2025-11-05 19:04:27.982995
1062	Fonamental	fonamental	other	2	1	2025-11-05 19:04:28.150089	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:28.150089	2025-11-05 19:04:28.150089
1063	econòmic	econòmic	other	2	1	2025-11-05 19:04:28.247458	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:28.247458	2025-11-05 19:04:28.247458
1064	pràctica	pràctica	other	2	1	2025-11-05 19:04:28.337736	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:28.337736	2025-11-05 19:04:28.337736
1065	PPEPC	ppepc	other	2	1	2025-11-05 19:04:28.417367	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:28.417367	2025-11-05 19:04:28.417367
1066	PPESA	ppesa	other	2	1	2025-11-05 19:04:28.496037	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:28.496037	2025-11-05 19:04:28.496037
1067	Exemples	exemples	other	2	1	2025-11-05 19:04:28.57411	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:28.57411	2025-11-05 19:04:28.57411
1068	Pràctics	pràctics	other	2	1	2025-11-05 19:04:28.638035	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:28.638035	2025-11-05 19:04:28.638035
1069	Fiscalitat	fiscalitat	other	2	1	2025-11-05 19:04:28.72827	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:28.72827	2025-11-05 19:04:28.72827
1070	dels	dels	other	2	1	2025-11-05 19:04:28.815894	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:28.815894	2025-11-05 19:04:28.815894
1071	productes	productes	other	2	1	2025-11-05 19:04:28.936389	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:28.936389	2025-11-05 19:04:28.936389
1072	financers	financers	other	2	1	2025-11-05 19:04:29.016157	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:29.016157	2025-11-05 19:04:29.016157
1073	ciberseguridad	ciberseguridad	other	2	1	2025-11-05 19:04:29.089698	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:29.089698	2025-11-05 19:04:29.089698
1074	brokers	brokers	other	2	1	2025-11-05 19:04:29.173821	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:29.173821	2025-11-05 19:04:29.173821
1075	visualízalos	visualízalos	other	2	1	2025-11-05 19:04:29.253154	Importada masivamente desde errores de spell check (freq: 2)	2025-11-05 19:04:29.253154	2025-11-05 19:04:29.253154
1076	Ariema	ariema	other	1	1	2025-11-05 19:04:29.32413	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:29.32413	2025-11-05 19:04:29.32413
1077	Blue	blue	other	1	1	2025-11-05 19:04:29.399781	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:29.399781	2025-11-05 19:04:29.399781
1078	EBITDA	ebitda	other	1	1	2025-11-05 19:04:29.521306	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:29.521306	2025-11-05 19:04:29.521306
1079	Norteamérica	norteamérica	other	1	1	2025-11-05 19:04:29.594435	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:29.594435	2025-11-05 19:04:29.594435
1080	BondFund	bondfund	other	1	1	2025-11-05 19:04:29.67629	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:29.67629	2025-11-05 19:04:29.67629
1081	IICs	iics	other	1	1	2025-11-05 19:04:29.796313	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:29.796313	2025-11-05 19:04:29.796313
1082	rentabilizarlo	rentabilizarlo	other	1	1	2025-11-05 19:04:29.87044	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:29.87044	2025-11-05 19:04:29.87044
1083	CDMO	cdmo	other	1	1	2025-11-05 19:04:29.942575	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:29.942575	2025-11-05 19:04:29.942575
1084	Arizona	arizona	other	1	1	2025-11-05 19:04:30.015297	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:30.015297	2025-11-05 19:04:30.015297
1085	Espana	espana	other	1	1	2025-11-05 19:04:30.097412	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:30.097412	2025-11-05 19:04:30.097412
1086	Latinoamerica	latinoamerica	other	1	1	2025-11-05 19:04:30.170864	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:30.170864	2025-11-05 19:04:30.170864
1087	retail	retail	other	1	1	2025-11-05 19:04:30.239975	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:30.239975	2025-11-05 19:04:30.239975
1088	Sustainable	sustainable	other	1	1	2025-11-05 19:04:30.315031	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:30.315031	2025-11-05 19:04:30.315031
1090	Management	management	other	1	1	2025-11-05 19:04:30.500191	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:30.500191	2025-11-05 19:04:30.500191
1091	North	north	other	1	1	2025-11-05 19:04:30.594435	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:30.594435	2025-11-05 19:04:30.594435
1092	reinvertidos	reinvertidos	other	1	1	2025-11-05 19:04:30.681435	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:30.681435	2025-11-05 19:04:30.681435
1093	activ	activ	other	1	1	2025-11-05 19:04:30.741405	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:30.741405	2025-11-05 19:04:30.741405
1094	retabilidad	retabilidad	other	1	1	2025-11-05 19:04:30.812786	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:30.812786	2025-11-05 19:04:30.812786
1095	mñas	mñas	other	1	1	2025-11-05 19:04:30.880108	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:30.880108	2025-11-05 19:04:30.880108
1097	Bnpp	bnpp	other	1	1	2025-11-05 19:04:31.064284	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:31.064284	2025-11-05 19:04:31.064284
1098	Insticash	insticash	other	1	1	2025-11-05 19:04:31.138299	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:31.138299	2025-11-05 19:04:31.138299
1099	Entreprises	entreprises	other	1	1	2025-11-05 19:04:31.235352	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:31.235352	2025-11-05 19:04:31.235352
1096	Reinversión	reinversión	other	2	1	2025-11-05 19:04:30.980319	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:30.980319	2025-11-05 19:04:33.059878
1055	cookies	cookies	other	3	1	2025-11-05 19:04:27.410562	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:27.410562	2025-11-05 19:04:38.923965
1056	multigestora	multigestora	other	4	1	2025-11-05 19:04:27.538457	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:27.538457	2025-11-05 19:04:44.841885
1050	Recíbelo	recíbelo	other	4	1	2025-11-05 19:04:26.902586	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:26.902586	2025-11-05 19:04:49.951668
1100	riesg	riesg	other	1	1	2025-11-05 19:04:31.321119	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:31.321119	2025-11-05 19:04:31.321119
1101	ompuestos	ompuestos	other	1	1	2025-11-05 19:04:31.413135	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:31.413135	2025-11-05 19:04:31.413135
1102	Seleccion	seleccion	other	1	1	2025-11-05 19:04:31.509647	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:31.509647	2025-11-05 19:04:31.509647
1103	disupuestos	disupuestos	other	1	1	2025-11-05 19:04:31.57968	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:31.57968	2025-11-05 19:04:31.57968
1104	Pegasus	pegasus	other	1	1	2025-11-05 19:04:31.643803	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:31.643803	2025-11-05 19:04:31.643803
1105	regulatorias	regulatorias	other	1	1	2025-11-05 19:04:31.737435	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:31.737435	2025-11-05 19:04:31.737435
1106	Alemania	alemania	other	1	1	2025-11-05 19:04:31.821931	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:31.821931	2025-11-05 19:04:31.821931
1107	Francia	francia	other	1	1	2025-11-05 19:04:31.91668	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:31.91668	2025-11-05 19:04:31.91668
1108	depositos	depositos	other	1	1	2025-11-05 19:04:31.993327	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:31.993327	2025-11-05 19:04:31.993327
1109	AEAT	aeat	other	1	1	2025-11-05 19:04:32.064462	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:32.064462	2025-11-05 19:04:32.064462
1110	Xetra	xetra	other	1	1	2025-11-05 19:04:32.151589	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:32.151589	2025-11-05 19:04:32.151589
1111	Ámstedam	ámstedam	other	1	1	2025-11-05 19:04:32.254324	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:32.254324	2025-11-05 19:04:32.254324
1112	Garatías	garatías	other	1	1	2025-11-05 19:04:32.340732	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:32.340732	2025-11-05 19:04:32.340732
1113	cupone	cupone	other	1	1	2025-11-05 19:04:32.456646	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:32.456646	2025-11-05 19:04:32.456646
1114	Audasa	audasa	other	1	1	2025-11-05 19:04:32.55628	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:32.55628	2025-11-05 19:04:32.55628
1115	Elecnor	elecnor	other	1	1	2025-11-05 19:04:32.626701	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:32.626701	2025-11-05 19:04:32.626701
1116	RBCs	rbcs	other	1	1	2025-11-05 19:04:32.689472	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:32.689472	2025-11-05 19:04:32.689472
1117	Perfilación	perfilación	other	1	1	2025-11-05 19:04:32.759718	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:32.759718	2025-11-05 19:04:32.759718
1089	Asset	asset	other	2	1	2025-11-05 19:04:30.390529	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:30.390529	2025-11-05 19:04:32.842763
1119	previsiblemente	previsiblemente	other	1	1	2025-11-05 19:04:32.934962	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:32.934962	2025-11-05 19:04:32.934962
1121	fjia	fjia	other	1	1	2025-11-05 19:04:33.179843	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:33.179843	2025-11-05 19:04:33.179843
1122	ORACLE	oracle	other	1	1	2025-11-05 19:04:33.258544	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:33.258544	2025-11-05 19:04:33.258544
1123	Jaime	jaime	other	1	1	2025-11-05 19:04:33.344139	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:33.344139	2025-11-05 19:04:33.344139
1124	Vázquez	vázquez	other	1	1	2025-11-05 19:04:33.432096	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:33.432096	2025-11-05 19:04:33.432096
1125	Payment	payment	other	1	1	2025-11-05 19:04:33.540477	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:33.540477	2025-11-05 19:04:33.540477
1126	Directive	directive	other	1	1	2025-11-05 19:04:33.624072	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:33.624072	2025-11-05 19:04:33.624072
1127	enalce	enalce	other	1	1	2025-11-05 19:04:33.68876	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:33.68876	2025-11-05 19:04:33.68876
1128	GRANOLAS	granolas	other	1	1	2025-11-05 19:04:33.771956	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:33.771956	2025-11-05 19:04:33.771956
1129	sobrevaloración	sobrevaloración	other	1	1	2025-11-05 19:04:33.842399	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:33.842399	2025-11-05 19:04:33.842399
1130	decisones	decisones	other	1	1	2025-11-05 19:04:33.908814	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:33.908814	2025-11-05 19:04:33.908814
1131	September	september	other	1	1	2025-11-05 19:04:33.987522	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:33.987522	2025-11-05 19:04:33.987522
1132	whale	whale	other	1	1	2025-11-05 19:04:34.077117	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:34.077117	2025-11-05 19:04:34.077117
1133	criptomercado	criptomercado	other	1	1	2025-11-05 19:04:34.164006	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:34.164006	2025-11-05 19:04:34.164006
1134	cypherpunk	cypherpunk	other	1	1	2025-11-05 19:04:34.236479	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:34.236479	2025-11-05 19:04:34.236479
1135	Crypto	crypto	other	1	1	2025-11-05 19:04:34.331028	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:34.331028	2025-11-05 19:04:34.331028
1136	Week	week	other	1	1	2025-11-05 19:04:34.418575	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:34.418575	2025-11-05 19:04:34.418575
1137	Assets	assets	other	1	1	2025-11-05 19:04:34.495479	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:34.495479	2025-11-05 19:04:34.495479
1138	definindo	definindo	other	1	1	2025-11-05 19:04:34.591269	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:34.591269	2025-11-05 19:04:34.591269
1139	comisones	comisones	other	1	1	2025-11-05 19:04:34.668584	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:34.668584	2025-11-05 19:04:34.668584
1140	Informate	informate	other	1	1	2025-11-05 19:04:34.751115	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:34.751115	2025-11-05 19:04:34.751115
1142	gestiónala	gestiónala	other	1	1	2025-11-05 19:04:34.908803	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:34.908803	2025-11-05 19:04:34.908803
1143	domicilación	domicilación	other	1	1	2025-11-05 19:04:34.971639	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:34.971639	2025-11-05 19:04:34.971639
1144	IVTM	ivtm	other	1	1	2025-11-05 19:04:35.043403	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:35.043403	2025-11-05 19:04:35.043403
1146	Bussines	bussines	other	1	1	2025-11-05 19:04:35.181718	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:35.181718	2025-11-05 19:04:35.181718
1147	School	school	other	1	1	2025-11-05 19:04:35.28481	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:35.28481	2025-11-05 19:04:35.28481
1148	Business	business	other	1	1	2025-11-05 19:04:35.371822	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:35.371822	2025-11-05 19:04:35.371822
1150	Quality	quality	other	1	1	2025-11-05 19:04:35.550036	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:35.550036	2025-11-05 19:04:35.550036
1151	Investing	investing	other	1	1	2025-11-05 19:04:35.643202	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:35.643202	2025-11-05 19:04:35.643202
1152	monitorean	monitorean	other	1	1	2025-11-05 19:04:35.720332	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:35.720332	2025-11-05 19:04:35.720332
1141	Actívala	actívala	other	2	1	2025-11-05 19:04:34.837648	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:34.837648	2025-11-05 19:04:44.450368
1153	Fernando	fernando	other	1	1	2025-11-05 19:04:35.797927	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:35.797927	2025-11-05 19:04:35.797927
1154	Latienda	latienda	other	1	1	2025-11-05 19:04:35.888142	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:35.888142	2025-11-05 19:04:35.888142
1155	playlists	playlists	other	1	1	2025-11-05 19:04:35.955026	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:35.955026	2025-11-05 19:04:35.955026
1156	MULTIGESTORAS	multigestoras	other	1	1	2025-11-05 19:04:36.024032	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:36.024032	2025-11-05 19:04:36.024032
1158	MONCLER	moncler	other	1	1	2025-11-05 19:04:36.259002	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:36.259002	2025-11-05 19:04:36.259002
1027	ArcelorMittal	arcelormittal	other	3	1	2025-11-05 19:04:23.930122	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:23.930122	2025-11-05 19:04:36.336446
1160	SOLARIA	solaria	other	1	1	2025-11-05 19:04:36.474499	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:36.474499	2025-11-05 19:04:36.474499
1161	EnergIA	energia	other	1	1	2025-11-05 19:04:36.545668	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:36.545668	2025-11-05 19:04:36.545668
1162	VALEO	valeo	other	1	1	2025-11-05 19:04:36.631528	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:36.631528	2025-11-05 19:04:36.631528
1163	decalaje	decalaje	other	1	1	2025-11-05 19:04:36.714365	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:36.714365	2025-11-05 19:04:36.714365
1165	pais	pais	other	1	1	2025-11-05 19:04:36.87787	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:36.87787	2025-11-05 19:04:36.87787
1166	Paperless	paperless	other	1	1	2025-11-05 19:04:36.955926	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:36.955926	2025-11-05 19:04:36.955926
1167	PPES	ppes	other	1	1	2025-11-05 19:04:37.077399	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:37.077399	2025-11-05 19:04:37.077399
1168	Autonomos	autonomos	other	1	1	2025-11-05 19:04:37.172562	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:37.172562	2025-11-05 19:04:37.172562
1170	biométrico	biométrico	other	1	1	2025-11-05 19:04:37.307149	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:37.307149	2025-11-05 19:04:37.307149
1171	Face	face	other	1	1	2025-11-05 19:04:37.385579	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:37.385579	2025-11-05 19:04:37.385579
1172	Touch	touch	other	1	1	2025-11-05 19:04:37.477473	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:37.477473	2025-11-05 19:04:37.477473
1173	Authenticator	authenticator	other	1	1	2025-11-05 19:04:37.613876	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:37.613876	2025-11-05 19:04:37.613876
1174	Basilea	basilea	other	1	1	2025-11-05 19:04:37.705329	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:37.705329	2025-11-05 19:04:37.705329
1175	AIAF	aiaf	other	1	1	2025-11-05 19:04:37.799127	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:37.799127	2025-11-05 19:04:37.799127
1176	SEND	send	other	1	1	2025-11-05 19:04:37.902277	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:37.902277	2025-11-05 19:04:37.902277
1177	Lacasa	lacasa	other	1	1	2025-11-05 19:04:38.020579	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:38.020579	2025-11-05 19:04:38.020579
1178	Kenia	kenia	other	1	1	2025-11-05 19:04:38.104136	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:38.104136	2025-11-05 19:04:38.104136
1179	Things	things	other	1	1	2025-11-05 19:04:38.182033	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:38.182033	2025-11-05 19:04:38.182033
1180	Happen	happen	other	1	1	2025-11-05 19:04:38.259609	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:38.259609	2025-11-05 19:04:38.259609
1181	Espadafor	espadafor	other	1	1	2025-11-05 19:04:38.331045	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:38.331045	2025-11-05 19:04:38.331045
1182	Abaitua	abaitua	other	1	1	2025-11-05 19:04:38.399852	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:38.399852	2025-11-05 19:04:38.399852
1184	IRUS	irus	other	1	1	2025-11-05 19:04:38.539626	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:38.539626	2025-11-05 19:04:38.539626
1185	LUXEMBURG	luxemburg	other	1	1	2025-11-05 19:04:38.620272	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:38.620272	2025-11-05 19:04:38.620272
1186	Commerce	commerce	other	1	1	2025-11-05 19:04:38.697297	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:38.697297	2025-11-05 19:04:38.697297
1187	Sociétés	sociétés	other	1	1	2025-11-05 19:04:38.763418	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:38.763418	2025-11-05 19:04:38.763418
1188	CSSF	cssf	other	1	1	2025-11-05 19:04:38.852179	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:38.852179	2025-11-05 19:04:38.852179
1190	dere	dere	other	1	1	2025-11-05 19:04:38.987469	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:38.987469	2025-11-05 19:04:38.987469
1191	stops	stops	other	1	1	2025-11-05 19:04:39.05947	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:39.05947	2025-11-05 19:04:39.05947
1193	diferen	diferen	other	1	1	2025-11-05 19:04:39.224234	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:39.224234	2025-11-05 19:04:39.224234
1194	dificil	dificil	other	1	1	2025-11-05 19:04:39.319103	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:39.319103	2025-11-05 19:04:39.319103
1195	repos	repos	other	1	1	2025-11-05 19:04:39.387054	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:39.387054	2025-11-05 19:04:39.387054
1197	introdu	introdu	other	1	1	2025-11-05 19:04:39.577197	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:39.577197	2025-11-05 19:04:39.577197
1198	Latinoamérica	latinoamérica	other	1	1	2025-11-05 19:04:39.644317	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:39.644317	2025-11-05 19:04:39.644317
1199	MILA	mila	other	1	1	2025-11-05 19:04:39.723273	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:39.723273	2025-11-05 19:04:39.723273
1200	México	méxico	other	1	1	2025-11-05 19:04:39.787708	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:39.787708	2025-11-05 19:04:39.787708
1201	Latam	latam	other	1	1	2025-11-05 19:04:39.848394	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:39.848394	2025-11-05 19:04:39.848394
1202	Private	private	other	1	1	2025-11-05 19:04:39.908902	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:39.908902	2025-11-05 19:04:39.908902
1203	DESCÁRGALA	descárgala	other	1	1	2025-11-05 19:04:39.970938	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:39.970938	2025-11-05 19:04:39.970938
1204	deducírtelo	deducírtelo	other	1	1	2025-11-05 19:04:40.043449	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:40.043449	2025-11-05 19:04:40.043449
1205	traves	traves	other	1	1	2025-11-05 19:04:40.110735	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:40.110735	2025-11-05 19:04:40.110735
1207	Numantia	numantia	other	1	1	2025-11-05 19:04:40.25178	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:40.25178	2025-11-05 19:04:40.25178
1208	Altair	altair	other	1	1	2025-11-05 19:04:40.316898	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:40.316898	2025-11-05 19:04:40.316898
1209	Dinamica	dinamica	other	1	1	2025-11-05 19:04:40.395698	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:40.395698	2025-11-05 19:04:40.395698
1210	OCDE	ocde	other	1	1	2025-11-05 19:04:40.46053	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:40.46053	2025-11-05 19:04:40.46053
1211	Endesa	endesa	other	1	1	2025-11-05 19:04:40.543672	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:40.543672	2025-11-05 19:04:40.543672
1212	Mapfre	mapfre	other	1	1	2025-11-05 19:04:40.624255	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:40.624255	2025-11-05 19:04:40.624255
1214	reinvertible	reinvertible	other	1	1	2025-11-05 19:04:40.774176	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:40.774176	2025-11-05 19:04:40.774176
1215	anualizadas	anualizadas	other	1	1	2025-11-05 19:04:40.857457	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:40.857457	2025-11-05 19:04:40.857457
1216	tram	tram	other	1	1	2025-11-05 19:04:40.925131	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:40.925131	2025-11-05 19:04:40.925131
1217	depositante	depositante	other	1	1	2025-11-05 19:04:41.021132	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:41.021132	2025-11-05 19:04:41.021132
1218	SEPE	sepe	other	1	1	2025-11-05 19:04:41.105885	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:41.105885	2025-11-05 19:04:41.105885
1219	resca	resca	other	1	1	2025-11-05 19:04:41.181816	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:41.181816	2025-11-05 19:04:41.181816
1220	cobrándolo	cobrándolo	other	1	1	2025-11-05 19:04:41.269202	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:41.269202	2025-11-05 19:04:41.269202
1221	Minificha	minificha	other	1	1	2025-11-05 19:04:41.362202	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:41.362202	2025-11-05 19:04:41.362202
1222	roll	roll	other	1	1	2025-11-05 19:04:41.434235	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:41.434235	2025-11-05 19:04:41.434235
1223	over	over	other	1	1	2025-11-05 19:04:41.509917	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:41.509917	2025-11-05 19:04:41.509917
1224	plane	plane	other	1	1	2025-11-05 19:04:41.581887	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:41.581887	2025-11-05 19:04:41.581887
1225	ímplicitos	ímplicitos	other	1	1	2025-11-05 19:04:41.652387	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:41.652387	2025-11-05 19:04:41.652387
1226	Securities	securities	other	1	1	2025-11-05 19:04:41.719466	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:41.719466	2025-11-05 19:04:41.719466
1227	SGFP	sgfp	other	1	1	2025-11-05 19:04:41.787003	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:41.787003	2025-11-05 19:04:41.787003
1228	restándole	restándole	other	1	1	2025-11-05 19:04:41.854419	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:41.854419	2025-11-05 19:04:41.854419
1229	Blend	blend	other	1	1	2025-11-05 19:04:41.948858	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:41.948858	2025-11-05 19:04:41.948858
1231	incial	incial	other	1	1	2025-11-05 19:04:42.077197	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:42.077197	2025-11-05 19:04:42.077197
1232	Ppsi	ppsi	other	1	1	2025-11-05 19:04:42.140046	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:42.140046	2025-11-05 19:04:42.140046
1233	desgravarnos	desgravarnos	other	1	1	2025-11-05 19:04:42.222542	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:42.222542	2025-11-05 19:04:42.222542
1145	Traders	traders	other	2	1	2025-11-05 19:04:35.111436	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:35.111436	2025-11-05 19:04:42.291528
1235	Filosofia	filosofia	other	1	1	2025-11-05 19:04:42.367452	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:42.367452	2025-11-05 19:04:42.367452
1237	órden	órden	other	1	1	2025-11-05 19:04:42.50327	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:42.50327	2025-11-05 19:04:42.50327
1238	center	center	other	1	1	2025-11-05 19:04:42.569464	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:42.569464	2025-11-05 19:04:42.569464
1239	cookie	cookie	other	1	1	2025-11-05 19:04:42.636663	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:42.636663	2025-11-05 19:04:42.636663
1240	mejorexperiencia	mejorexperiencia	other	1	1	2025-11-05 19:04:42.725626	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:42.725626	2025-11-05 19:04:42.725626
1183	SIGRUN	sigrun	other	2	1	2025-11-05 19:04:38.46965	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:38.46965	2025-11-05 19:04:42.835592
1242	tablets	tablets	other	1	1	2025-11-05 19:04:42.9016	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:42.9016	2025-11-05 19:04:42.9016
1243	clicando	clicando	other	1	1	2025-11-05 19:04:42.995883	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:42.995883	2025-11-05 19:04:42.995883
1244	comportamental	comportamental	other	1	1	2025-11-05 19:04:43.094929	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:43.094929	2025-11-05 19:04:43.094929
1245	Banner	banner	other	1	1	2025-11-05 19:04:43.179984	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:43.179984	2025-11-05 19:04:43.179984
1246	Chrome	chrome	other	1	1	2025-11-05 19:04:43.263137	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:43.263137	2025-11-05 19:04:43.263137
1247	Mozilla	mozilla	other	1	1	2025-11-05 19:04:43.347334	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:43.347334	2025-11-05 19:04:43.347334
1248	Firefox	firefox	other	1	1	2025-11-05 19:04:43.429609	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:43.429609	2025-11-05 19:04:43.429609
1249	Edge	edge	other	1	1	2025-11-05 19:04:43.507457	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:43.507457	2025-11-05 19:04:43.507457
1250	Target	target	other	1	1	2025-11-05 19:04:43.607707	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:43.607707	2025-11-05 19:04:43.607707
1251	Entity	entity	other	1	1	2025-11-05 19:04:43.67637	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:43.67637	2025-11-05 19:04:43.67637
1252	Identifier	identifier	other	1	1	2025-11-05 19:04:43.742278	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:43.742278	2025-11-05 19:04:43.742278
1253	MiFIR	mifir	other	1	1	2025-11-05 19:04:43.819579	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:43.819579	2025-11-05 19:04:43.819579
1256	Store	store	other	1	1	2025-11-05 19:04:44.06954	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:44.06954	2025-11-05 19:04:44.06954
1257	Play	play	other	1	1	2025-11-05 19:04:44.162341	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:44.162341	2025-11-05 19:04:44.162341
1258	Ruralvía	ruralvía	other	1	1	2025-11-05 19:04:44.240784	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:44.240784	2025-11-05 19:04:44.240784
1259	Automátic	automátic	other	1	1	2025-11-05 19:04:44.342167	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:44.342167	2025-11-05 19:04:44.342167
1261	cualqueira	cualqueira	other	1	1	2025-11-05 19:04:44.552508	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:44.552508	2025-11-05 19:04:44.552508
1262	Ultrainversos	ultrainversos	other	1	1	2025-11-05 19:04:44.62314	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:44.62314	2025-11-05 19:04:44.62314
1263	Traded	traded	other	1	1	2025-11-05 19:04:44.692268	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:44.692268	2025-11-05 19:04:44.692268
1266	CARMINGNAC	carmingnac	other	1	1	2025-11-05 19:04:44.922219	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:44.922219	2025-11-05 19:04:44.922219
1267	Trump	trump	other	1	1	2025-11-05 19:04:45.044865	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:45.044865	2025-11-05 19:04:45.044865
1268	Rusia	rusia	other	1	1	2025-11-05 19:04:45.133956	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:45.133956	2025-11-05 19:04:45.133956
1269	Descúbrelos	descúbrelos	other	1	1	2025-11-05 19:04:45.221496	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:45.221496	2025-11-05 19:04:45.221496
1270	mens	mens	other	1	1	2025-11-05 19:04:45.316663	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:45.316663	2025-11-05 19:04:45.316663
1271	Alpes	alpes	other	1	1	2025-11-05 19:04:45.383701	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:45.383701	2025-11-05 19:04:45.383701
1272	Phix	phix	other	1	1	2025-11-05 19:04:45.500192	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:45.500192	2025-11-05 19:04:45.500192
1273	chartista	chartista	other	1	1	2025-11-05 19:04:45.581361	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:45.581361	2025-11-05 19:04:45.581361
1274	analysis	analysis	other	1	1	2025-11-05 19:04:45.688449	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:45.688449	2025-11-05 19:04:45.688449
1275	parquet	parquet	other	1	1	2025-11-05 19:04:45.760375	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:45.760375	2025-11-05 19:04:45.760375
1276	amplisima	amplisima	other	1	1	2025-11-05 19:04:45.830974	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:45.830974	2025-11-05 19:04:45.830974
1279	Food	food	other	1	1	2025-11-05 19:04:46.156955	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:46.156955	2025-11-05 19:04:46.156955
1280	Tech	tech	other	1	1	2025-11-05 19:04:46.242202	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:46.242202	2025-11-05 19:04:46.242202
1281	City	city	other	1	1	2025-11-05 19:04:46.322323	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:46.322323	2025-11-05 19:04:46.322323
1282	Videovigilancia	videovigilancia	other	1	1	2025-11-05 19:04:46.414408	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:46.414408	2025-11-05 19:04:46.414408
1283	Descorrelación	descorrelación	other	1	1	2025-11-05 19:04:46.516109	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:46.516109	2025-11-05 19:04:46.516109
1284	criptos	criptos	other	1	1	2025-11-05 19:04:46.606326	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:46.606326	2025-11-05 19:04:46.606326
1285	Ripple	ripple	other	1	1	2025-11-05 19:04:46.685304	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:46.685304	2025-11-05 19:04:46.685304
1286	Cardano	cardano	other	1	1	2025-11-05 19:04:46.767259	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:46.767259	2025-11-05 19:04:46.767259
1287	Chainlink	chainlink	other	1	1	2025-11-05 19:04:46.841366	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:46.841366	2025-11-05 19:04:46.841366
1288	Stellar	stellar	other	1	1	2025-11-05 19:04:46.905736	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:46.905736	2025-11-05 19:04:46.905736
1289	Polkadot	polkadot	other	1	1	2025-11-05 19:04:47.012093	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:47.012093	2025-11-05 19:04:47.012093
1290	regulatoria	regulatoria	other	1	1	2025-11-05 19:04:47.095132	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:47.095132	2025-11-05 19:04:47.095132
1291	iliquidez	iliquidez	other	1	1	2025-11-05 19:04:47.182841	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:47.182841	2025-11-05 19:04:47.182841
1292	hackear	hackear	other	1	1	2025-11-05 19:04:47.273575	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:47.273575	2025-11-05 19:04:47.273575
1293	ETNs	etns	other	1	1	2025-11-05 19:04:47.356188	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:47.356188	2025-11-05 19:04:47.356188
1294	token	token	other	1	1	2025-11-05 19:04:47.502667	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:47.502667	2025-11-05 19:04:47.502667
1295	criptoactivo	criptoactivo	other	1	1	2025-11-05 19:04:47.602035	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:47.602035	2025-11-05 19:04:47.602035
1296	NFTs	nfts	other	1	1	2025-11-05 19:04:47.693513	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:47.693513	2025-11-05 19:04:47.693513
1297	Tokens	tokens	other	1	1	2025-11-05 19:04:47.81763	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:47.81763	2025-11-05 19:04:47.81763
1298	Contrátala	contrátala	other	1	1	2025-11-05 19:04:47.918881	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:47.918881	2025-11-05 19:04:47.918881
1299	experienca	experienca	other	1	1	2025-11-05 19:04:47.991282	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:47.991282	2025-11-05 19:04:47.991282
1300	apalan	apalan	other	1	1	2025-11-05 19:04:48.105792	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:48.105792	2025-11-05 19:04:48.105792
1301	TDax	tdax	other	1	1	2025-11-05 19:04:48.214076	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:48.214076	2025-11-05 19:04:48.214076
1302	MDax	mdax	other	1	1	2025-11-05 19:04:48.286183	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:48.286183	2025-11-05 19:04:48.286183
1303	Bund	bund	other	1	1	2025-11-05 19:04:48.358158	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:48.358158	2025-11-05 19:04:48.358158
1304	Bobl	bobl	other	1	1	2025-11-05 19:04:48.420259	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:48.420259	2025-11-05 19:04:48.420259
1305	Schatz	schatz	other	1	1	2025-11-05 19:04:48.480992	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:48.480992	2025-11-05 19:04:48.480992
1306	LONG	long	other	1	1	2025-11-05 19:04:48.557828	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:48.557828	2025-11-05 19:04:48.557828
1307	fiscalmente	fiscalmente	other	1	1	2025-11-05 19:04:48.627772	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:48.627772	2025-11-05 19:04:48.627772
1308	Broke	broke	other	1	1	2025-11-05 19:04:48.720448	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:48.720448	2025-11-05 19:04:48.720448
1309	Fully	fully	other	1	1	2025-11-05 19:04:48.821849	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:48.821849	2025-11-05 19:04:48.821849
1310	regulatorios	regulatorios	other	1	1	2025-11-05 19:04:48.899721	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:48.899721	2025-11-05 19:04:48.899721
1311	Greenspan	greenspan	other	1	1	2025-11-05 19:04:49.004775	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:49.004775	2025-11-05 19:04:49.004775
1312	superliquidez	superliquidez	other	1	1	2025-11-05 19:04:49.109787	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:49.109787	2025-11-05 19:04:49.109787
1313	interrelaciona	interrelaciona	other	1	1	2025-11-05 19:04:49.19411	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:49.19411	2025-11-05 19:04:49.19411
1314	Característicias	característicias	other	1	1	2025-11-05 19:04:49.275953	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:49.275953	2025-11-05 19:04:49.275953
1315	ejectuar	ejectuar	other	1	1	2025-11-05 19:04:49.357958	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:49.357958	2025-11-05 19:04:49.357958
1316	splits	splits	other	1	1	2025-11-05 19:04:49.433129	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:49.433129	2025-11-05 19:04:49.433129
1317	nuetro	nuetro	other	1	1	2025-11-05 19:04:49.504653	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:49.504653	2025-11-05 19:04:49.504653
1318	nuetras	nuetras	other	1	1	2025-11-05 19:04:49.571803	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:49.571803	2025-11-05 19:04:49.571803
1319	hardware	hardware	other	1	1	2025-11-05 19:04:49.641725	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:49.641725	2025-11-05 19:04:49.641725
1320	Geolocalización	geolocalización	other	1	1	2025-11-05 19:04:49.706682	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:49.706682	2025-11-05 19:04:49.706682
1321	Scrip	scrip	other	1	1	2025-11-05 19:04:49.781236	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:49.781236	2025-11-05 19:04:49.781236
1322	reinvertirlos	reinvertirlos	other	1	1	2025-11-05 19:04:49.871351	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:49.871351	2025-11-05 19:04:49.871351
1324	PIAS	pias	other	1	1	2025-11-05 19:04:50.03212	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:50.03212	2025-11-05 19:04:50.03212
1325	SIALP	sialp	other	1	1	2025-11-05 19:04:50.117152	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:50.117152	2025-11-05 19:04:50.117152
1326	Unit	unit	other	1	1	2025-11-05 19:04:50.193367	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:50.193367	2025-11-05 19:04:50.193367
1327	liquidarlos	liquidarlos	other	1	1	2025-11-05 19:04:50.289304	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:50.289304	2025-11-05 19:04:50.289304
1328	spot	spot	other	1	1	2025-11-05 19:04:50.37236	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:50.37236	2025-11-05 19:04:50.37236
1329	forward	forward	other	1	1	2025-11-05 19:04:50.450416	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:50.450416	2025-11-05 19:04:50.450416
1330	singapuriense	singapuriense	other	1	1	2025-11-05 19:04:50.534621	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:50.534621	2025-11-05 19:04:50.534621
1331	Zloty	zloty	other	1	1	2025-11-05 19:04:50.611178	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:50.611178	2025-11-05 19:04:50.611178
1332	OTCs	otcs	other	1	1	2025-11-05 19:04:50.699088	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:50.699088	2025-11-05 19:04:50.699088
1333	Multiples	multiples	other	1	1	2025-11-05 19:04:50.778664	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:50.778664	2025-11-05 19:04:50.778664
1334	FGDEC	fgdec	other	1	1	2025-11-05 19:04:50.868501	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:50.868501	2025-11-05 19:04:50.868501
1336	captial	captial	other	1	1	2025-11-05 19:04:51.036131	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:51.036131	2025-11-05 19:04:51.036131
1338	reinversiones	reinversiones	other	1	1	2025-11-05 19:04:51.202076	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:51.202076	2025-11-05 19:04:51.202076
1339	Covid	covid	other	1	1	2025-11-05 19:04:51.278599	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:51.278599	2025-11-05 19:04:51.278599
1340	correlacionados	correlacionados	other	1	1	2025-11-05 19:04:51.380485	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:51.380485	2025-11-05 19:04:51.380485
1341	ecomendaciones	ecomendaciones	other	1	1	2025-11-05 19:04:51.46937	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:51.46937	2025-11-05 19:04:51.46937
1343	deleges	deleges	other	1	1	2025-11-05 19:04:51.631279	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:51.631279	2025-11-05 19:04:51.631279
1345	repórtalo	repórtalo	other	1	1	2025-11-05 19:04:51.771825	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:51.771825	2025-11-05 19:04:51.771825
1346	ciberdelincuentes	ciberdelincuentes	other	1	1	2025-11-05 19:04:51.866363	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:51.866363	2025-11-05 19:04:51.866363
1347	Denúncialo	denúncialo	other	1	1	2025-11-05 19:04:51.948925	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:51.948925	2025-11-05 19:04:51.948925
1348	facilítanos	facilítanos	other	1	1	2025-11-05 19:04:52.04649	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:52.04649	2025-11-05 19:04:52.04649
1349	CallCenter	callcenter	other	1	1	2025-11-05 19:04:52.130953	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:52.130953	2025-11-05 19:04:52.130953
1350	Infórmanos	infórmanos	other	1	1	2025-11-05 19:04:52.234784	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:52.234784	2025-11-05 19:04:52.234784
1351	recházala	recházala	other	1	1	2025-11-05 19:04:52.323505	Importada masivamente desde errores de spell check (freq: 1)	2025-11-05 19:04:52.323505	2025-11-05 19:04:52.323505
\.


--
-- Data for Name: discovered_urls; Type: TABLE DATA; Schema: public; Owner: jesusramos
--

COPY public.discovered_urls (id, url, parent_url_id, depth, discovered_at, last_checked, status_code, response_time, is_broken, error_message, active, crawl_run_id, is_priority) FROM stdin;
4	https://www.r4.com/login	2	1	2025-11-04 21:20:37.088645	2025-11-05 07:41:36.276188	\N	\N	f	\N	t	4	f
1971	https://www.r4.com/articulos-y-analisis/valores/acx-compra-del-100-de-haynes-international	1528	6	2025-11-04 22:11:21.19415	2025-11-05 08:30:49.901739	\N	\N	f	\N	t	4	f
1932	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/las-bolsas-europeas-prosiguen-su-despegue-pero-es-un-juego-de-suma-cero	1488	6	2025-11-04 22:10:18.305689	2025-11-05 08:29:59.400237	\N	\N	f	\N	t	4	f
1973	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-contrato-en-arabia-saudi	1538	6	2025-11-04 22:11:23.82876	2025-11-05 08:30:54.561157	\N	\N	f	\N	t	4	f
1974	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-2024-cumpliendo-con-lo-prometido-y-guidance-mejor-de-lo-esperado	1538	6	2025-11-04 22:11:25.075209	2025-11-05 08:30:55.807282	\N	\N	f	\N	t	4	f
2015	https://www.r4.com/articulos-y-analisis/valores/santander-vende-su-participacion-en-caceis	1596	6	2025-11-04 22:12:37.946649	2025-11-05 08:31:48.563725	\N	\N	f	\N	t	4	f
3	https://www.r4.com/abrir-cuenta	2	1	2025-11-04 21:20:35.713258	2025-11-05 07:41:34.904854	\N	\N	f	\N	t	4	f
4469	https://www.r4.com/politica-cookies	4183	7	2025-11-05 08:42:11.5775	\N	\N	\N	f	\N	t	4	f
350	https://www.r4.com/goto/aviso-legal	41	2	2025-11-04 21:28:18.717304	2025-11-05 07:48:54.622442	\N	\N	f	\N	t	4	f
56	https://www.r4.com/portal?TX=goto&FWD=ETF_GESTORAS&PAG=2&SUB_HOJA=1	2	1	2025-11-04 21:21:46.436986	2025-11-05 07:42:39.249403	\N	\N	f	\N	t	4	f
496	https://www.r4.com/content/rentabanco/r4/es/serviciosr4/formacion/empezar-invertir	109	2	2025-11-04 21:31:51.243452	2025-11-05 07:52:18.022382	\N	\N	f	\N	t	4	f
5	https://www.r4.com/portal?TX=logout	2	1	2025-11-04 21:20:38.256302	2025-11-05 07:41:37.418186	\N	\N	f	\N	t	4	f
6	https://www.r4.com/portal?TX=goto&FWD=MAIN10&PAG=0	2	1	2025-11-04 21:20:39.403563	2025-11-05 07:41:38.596977	\N	\N	f	\N	t	4	f
7	https://www.r4.com/portal?TX=goto&FWD=MAIN10	2	1	2025-11-04 21:20:40.504273	2025-11-05 07:41:39.726639	\N	\N	f	\N	t	4	f
40	https://www.r4.com/portal?TX=goto&FWD=MAIN11&PORTLET=BLS002&PAG=1	2	1	2025-11-04 21:21:27.869926	2025-11-05 07:42:20.451468	\N	\N	f	\N	t	4	f
41	https://www.r4.com/portal?TX=comparativa&OPC=3&PAG=1&HOJA=5&SUB_PEST=3	2	1	2025-11-04 21:21:28.968218	2025-11-05 07:42:21.87624	\N	\N	f	\N	t	4	f
43	https://www.r4.com/portal?TX=goto&FWD=BLS009&PAG=1&HOJA=3	2	1	2025-11-04 21:21:31.268973	2025-11-05 07:42:24.223714	\N	\N	f	\N	t	4	f
44	https://www.r4.com/portal?TX=goto&FWD=MPF003&PAG=14&HOJA=6&SERVICIO=TRADER	2	1	2025-11-04 21:21:32.395433	2025-11-05 07:42:25.410267	\N	\N	f	\N	t	4	f
45	https://www.r4.com/portal?TX=bolsas&CAB2=1-1&PAG=1&HOJA=2&SUB_HOJ=5	2	1	2025-11-04 21:21:33.553285	2025-11-05 07:42:26.50868	\N	\N	f	\N	t	4	f
46	https://www.r4.com/portal?TX=noticias&OPC=6&PAG=1&HOJA=0&SUB_PEST=1	2	1	2025-11-04 21:21:34.895751	2025-11-05 07:42:27.76975	\N	\N	f	\N	t	4	f
47	https://www.r4.com/portal?TX=comparativa&OPC=6&MKT=IBEX%2035%24MCO%3BIND&CAB=9&PAG=1&HOJA=6&SUB_PEST=2&TAB=1	2	1	2025-11-04 21:21:36.0537	2025-11-05 07:42:28.898864	\N	\N	f	\N	t	4	f
48	https://www.r4.com/portal?TX=comparativa&OPC=6&MKT=IBEX%2035$IND%3BMCO&CAB=9&PAG=1&HOJA=6&SUB_PEST=2&SUB_HOJA=0&TAB=2	2	1	2025-11-04 21:21:37.273113	2025-11-05 07:42:30.20421	\N	\N	f	\N	t	4	f
49	https://www.r4.com/portal?TX=goto&FWD=ANAP004&PAG=1&HOJA=0&SUB_HOJA=0&SUB_PEST=2	2	1	2025-11-04 21:21:38.47029	2025-11-05 07:42:31.486325	\N	\N	f	\N	t	4	f
50	https://www.r4.com/portal?TX=goto&FWD=DIV001&PAG=1&SUB_PEST=2&HOJA=5&SUB_HOJA=0	2	1	2025-11-04 21:21:39.620129	2025-11-05 07:42:32.588935	\N	\N	f	\N	t	4	f
51	https://www.r4.com/portal?TX=goto&FWD=MAIN_ETF&PORTLET=MAIN_ETF&PAG=2&SUB_HOJ=1	2	1	2025-11-04 21:21:40.766874	2025-11-05 07:42:33.700785	\N	\N	f	\N	t	4	f
52	https://www.r4.com/portal?TX=goto&FWD=ETF_DESTACADOS&PAG=2&SUB_HOJ=5	2	1	2025-11-04 21:21:41.977308	2025-11-05 07:42:34.844599	\N	\N	f	\N	t	4	f
53	https://www.r4.com/portal?TX=goto&FWD=ETF_SELECTOR&PAG=2&SUB_HOJ=2	2	1	2025-11-04 21:21:43.102214	2025-11-05 07:42:35.945055	\N	\N	f	\N	t	4	f
55	https://www.r4.com/portal?TX=goto&FWD=BUSCADOR_ETF_COMPARADOR&PAG=2&SUB_HOJ=4	2	1	2025-11-04 21:21:45.324629	2025-11-05 07:42:38.144399	\N	\N	f	\N	t	4	f
349	https://www.r4.com/goto/tablon-anuncios	41	2	2025-11-04 21:28:17.404727	2025-11-05 07:48:53.350309	\N	\N	f	\N	t	4	f
57	https://www.r4.com/portal?TX=carteras&OPC=37&HOJA=4&INT=7&CAB=10&PAG=11	2	1	2025-11-04 21:21:47.597637	2025-11-05 07:42:40.365037	\N	\N	f	\N	t	4	f
58	https://www.r4.com/portal?TX=goto&FWD=CFD003&HOJA=3&PAG=11	2	1	2025-11-04 21:21:48.711208	2025-11-05 07:42:41.463998	\N	\N	f	\N	t	4	f
59	https://www.r4.com/portal?TX=carteras&OPC=37&INT=4&PAG=8&HOJA=1&CAB=8	2	1	2025-11-04 21:21:49.913873	2025-11-05 07:42:42.583923	\N	\N	f	\N	t	4	f
506	https://www.r4.com/serviciosr4/como-elegir-los-mejores-fondos-de-inversion	110	2	2025-11-04 21:32:04.884762	2025-11-05 07:52:30.548813	\N	\N	f	\N	t	4	f
61	https://www.r4.com/portal?TX=goto&FWD=DER015&PORTLET=DRV001&PAG=8	2	1	2025-11-04 21:21:52.150248	2025-11-05 07:42:44.810398	\N	\N	f	\N	t	4	f
62	https://www.r4.com/portal?TX=goto&FWD=DER058&COD=OPC&CAB=8&PAG=8&HOJA=0	2	1	2025-11-04 21:21:53.324512	2025-11-05 07:42:45.973577	\N	\N	f	\N	t	4	f
63	https://www.r4.com/portal?TX=goto&FWD=MAIN122&PAG=71&HOJA=2	2	1	2025-11-04 21:21:54.439756	2025-11-05 07:42:47.089274	\N	\N	f	\N	t	4	f
64	https://www.r4.com/portal?TX=goto&FWD=SIMULADOR_OPCIONES&PAG=8	2	1	2025-11-04 21:21:55.555595	2025-11-05 07:42:48.19691	\N	\N	f	\N	t	4	f
65	https://www.r4.com/portal?TX=carteras&OPC=37&PAG=8&HOJA=5&CAB=7&INT=3	2	1	2025-11-04 21:21:56.661591	2025-11-05 07:42:49.323217	\N	\N	f	\N	t	4	f
66	https://www.r4.com/portal?TX=buscador_fnd&OPC=4&PAG=8	2	1	2025-11-04 21:21:57.767888	2025-11-05 07:42:50.454544	\N	\N	f	\N	t	4	f
72	https://www.r4.com/renta-fija/que-es-renta-fija	2	1	2025-11-04 21:22:04.871754	2025-11-05 07:42:57.385754	\N	\N	f	\N	t	4	f
73	https://www.r4.com/portal?TX=carteras&OPC=37&PAG=13&HOJA=3&DST=8&INT=8	2	1	2025-11-04 21:22:06.08765	2025-11-05 07:42:58.58779	\N	\N	f	\N	t	4	f
74	https://www.r4.com/portal?TX=goto&FWD=RF_SEC&PAG=13&HOJA=6	2	1	2025-11-04 21:22:07.195247	2025-11-05 07:42:59.730496	\N	\N	f	\N	t	4	f
75	https://www.r4.com/portal?TX=goto&FWD=RF_TW&PAG=13&HOJA=5	2	1	2025-11-04 21:22:08.320553	2025-11-05 07:43:00.827184	\N	\N	f	\N	t	4	f
76	https://www.r4.com/portal?TX=goto&FWD=LETRAS_TESORO&PAG=13&HOJA=5	2	1	2025-11-04 21:22:09.438042	2025-11-05 07:43:01.92563	\N	\N	f	\N	t	4	f
77	https://www.r4.com/portal?TX=goto&FWD=BONOS&PAG=13&HOJA=5	2	1	2025-11-04 21:22:10.551921	2025-11-05 07:43:03.051006	\N	\N	f	\N	t	4	f
78	https://www.r4.com/portal?TX=buscador_fnd&OPC=23&PAG=13&HOJA=2	2	1	2025-11-04 21:22:11.656105	2025-11-05 07:43:04.167292	\N	\N	f	\N	t	4	f
87	https://www.r4.com/articulos-y-analisis/valores	2	1	2025-11-04 21:22:22.590537	2025-11-05 07:43:15.729994	\N	\N	f	\N	t	4	f
92	https://www.r4.com/serviciosr4/fondotop-plataforma-online-operar-con-fondos-inversion	2	1	2025-11-04 21:22:28.480099	2025-11-05 07:43:21.475863	\N	\N	f	\N	t	4	f
94	https://www.r4.com/new?TX=goto&FWD=APERTURA-CUENTA&PORTLET=APE001&	2	1	2025-11-04 21:22:30.852082	2025-11-05 07:43:23.986576	\N	\N	f	\N	t	4	f
95	https://www.r4.com/portal?FWD=APERSY&TX=goto	2	1	2025-11-04 21:22:32.050978	2025-11-05 07:43:25.325798	\N	\N	f	\N	t	4	f
96	https://www.r4.com/fondos-de-inversion/fondos/ES0173130024	2	1	2025-11-04 21:22:33.242573	2025-11-05 07:43:26.506403	\N	\N	f	\N	t	4	f
97	https://www.r4.com/fondos-de-inversion/fondos/ES0173394034	2	1	2025-11-04 21:22:34.533689	2025-11-05 07:43:27.684868	\N	\N	f	\N	t	4	f
98	https://www.r4.com/fondos-de-inversion/fondos/ES0173130065	2	1	2025-11-04 21:22:35.80191	2025-11-05 07:43:28.952202	\N	\N	f	\N	t	4	f
99	https://www.r4.com/fondos-de-inversion/fondos/ES0173128002	2	1	2025-11-04 21:22:37.230098	2025-11-05 07:43:30.163652	\N	\N	f	\N	t	4	f
112	https://www.r4.com/inversion-para-todos	2	1	2025-11-04 21:22:53.549146	2025-11-05 07:43:45.525145	\N	\N	f	\N	t	4	f
68	https://www.r4.com/renta-fija	2	1	2025-11-04 21:22:00.012749	2025-11-05 07:42:52.709616	\N	\N	f	\N	t	4	t
121	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=AGS&TIPOCARTERA=18	10	2	2025-11-04 21:23:04.9029	2025-11-05 07:43:56.382553	\N	\N	f	\N	t	4	f
122	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=AGS&TIPOCARTERA=19	14	2	2025-11-04 21:23:06.054855	2025-11-05 07:43:57.521249	\N	\N	f	\N	t	4	f
556	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0157097017	136	3	2025-11-04 21:33:17.51885	2025-11-05 07:53:41.453326	\N	\N	f	\N	t	4	f
124	https://www.r4.com/articulos-y-analisis/valores/bbva-dinamismo-comercial-y-productos-generadores-de-comisiones	16	2	2025-11-04 21:23:08.336133	2025-11-05 07:43:59.824438	\N	\N	f	\N	t	4	f
125	https://www.r4.com/articulos-y-analisis/valores/conclusiones-enagas-1s25-la-resolucion-de-incertidumbres-clave-para-mejora-de-cotizacion	16	2	2025-11-04 21:23:09.495736	2025-11-05 07:44:01.014108	\N	\N	f	\N	t	4	f
126	https://www.r4.com/articulos-y-analisis/valores/endesa-1s25-resultados-en-linea-pendientes-de-comentarios-del-equipo-directivo	16	2	2025-11-04 21:23:10.73989	2025-11-05 07:44:02.184808	\N	\N	f	\N	t	4	f
127	https://www.r4.com/articulos-y-analisis/valores/ferrovial-1s25-autopistas-y-margenes-de-construccion-mejoran-nuestra-prevision	16	2	2025-11-04 21:23:11.961503	2025-11-05 07:44:03.560711	\N	\N	f	\N	t	4	f
129	https://www.r4.com/articulos-y-analisis/valores/rovi-1t25-eleva-los-resultados-al-registrar-menores-costes-de-los-previstos	16	2	2025-11-04 21:23:14.439717	2025-11-05 07:44:07.093577	\N	\N	f	\N	t	4	f
130	https://www.r4.com/articulos-y-analisis/valores/mapfre-1s25-buenos-niveles-de-ratio-combinado-apoyado-por-primas-y-gestion-tecnica	16	2	2025-11-04 21:23:15.79539	2025-11-05 07:44:08.536614	\N	\N	f	\N	t	4	f
131	https://www.r4.com/articulos-y-analisis/valores/sacyr-1s25-p-l-mejora-previsiones-pero-la-deuda-neta-con-recurso-alineada-con-lo-previsto	16	2	2025-11-04 21:23:16.998554	2025-11-05 07:44:09.707703	\N	\N	f	\N	t	4	f
132	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=AGS&TIPOCARTERA=1&CARTERA=ESP	17	2	2025-11-04 21:23:18.25296	2025-11-05 07:44:10.880184	\N	\N	f	\N	t	4	f
133	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-2t25-ebitda-principal-magnitud-en-linea-revisan-a-la-baja-prevision-de-demanda-en-norteamerica	17	2	2025-11-04 21:23:19.416049	2025-11-05 07:44:12.040183	\N	\N	f	\N	t	4	f
134	https://www.r4.com/articulos-y-analisis/valores/cirsa-2t25-buenos-resultados-en-camino-para-alcanzar-el-guidance	17	2	2025-11-04 21:23:20.59474	2025-11-05 07:44:13.305271	\N	\N	f	\N	t	4	f
135	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=AGS&TIPOCARTERA=1&CARTERA=VRS	18	2	2025-11-04 21:23:21.807972	2025-11-05 07:44:15.603773	\N	\N	f	\N	t	4	f
136	https://www.r4.com/articulos-y-analisis/valores/almirall-2t25-fuerte-crecimiento-aunque-no-termina-de-rentabilizarlo	18	2	2025-11-04 21:23:22.966126	2025-11-05 07:44:16.781209	\N	\N	f	\N	t	4	f
137	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-1t25-los-resultados-2t-seran-mejores-que-los-de-1t-optimismo-con-el-plan-de-accion-en-europa	18	2	2025-11-04 21:23:24.216473	2025-11-05 07:44:19.129097	\N	\N	f	\N	t	4	f
138	https://www.r4.com/articulos-y-analisis/valores/iag-entra-en-el-indice-msci-world-index	18	2	2025-11-04 21:23:25.49242	2025-11-05 07:44:20.356103	\N	\N	f	\N	t	4	f
139	https://www.r4.com/articulos-y-analisis/valores/rovi-fortalece-su-actividad-de-cdmo-al-adquirir-una-planta-en-arizona	18	2	2025-11-04 21:23:26.727378	2025-11-05 07:44:21.542916	\N	\N	f	\N	t	4	f
140	https://www.r4.com/articulos-y-analisis/valores/merlin-properties-1t25-mayor-apalancamiento-operativo-del-esperado	18	2	2025-11-04 21:23:28.904539	2025-11-05 07:44:22.704855	\N	\N	f	\N	t	4	f
161	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FR4	22	2	2025-11-04 21:23:58.34586	2025-11-05 07:44:51.218416	\N	\N	f	\N	t	4	f
162	https://www.r4.com/fondos-de-inversion/fondos/ES0113118006	22	2	2025-11-04 21:23:59.513279	2025-11-05 07:44:52.420901	\N	\N	f	\N	t	4	f
164	https://www.r4.com/fondos-de-inversion/fondos/ES0173320039	22	2	2025-11-04 21:24:02.043282	2025-11-05 07:44:54.785338	\N	\N	f	\N	t	4	f
165	https://www.r4.com/fondos-de-inversion/fondos/ES0173057011	22	2	2025-11-04 21:24:03.346981	2025-11-05 07:44:56.035714	\N	\N	f	\N	t	4	f
166	https://www.r4.com/fondos-de-inversion/fondos/LU0224105477	22	2	2025-11-04 21:24:04.567294	2025-11-05 07:44:57.230312	\N	\N	f	\N	t	4	f
167	https://www.r4.com/fondos-de-inversion/fondos/LU0210534227	22	2	2025-11-04 21:24:05.789579	2025-11-05 07:44:58.394821	\N	\N	f	\N	t	4	f
168	https://www.r4.com/fondos-de-inversion/fondos/LU0573559563	22	2	2025-11-04 21:24:07.038019	2025-11-05 07:44:59.631888	\N	\N	f	\N	t	4	f
169	https://www.r4.com/fondos-de-inversion/fondos/LU0787776565	22	2	2025-11-04 21:24:08.386483	2025-11-05 07:45:00.787438	\N	\N	f	\N	t	4	f
170	https://www.r4.com/fondos-de-inversion/fondos/ES0115279012	22	2	2025-11-04 21:24:09.653283	2025-11-05 07:45:02.06025	\N	\N	f	\N	t	4	f
171	https://www.r4.com/fondos-de-inversion/fondos/ES0166932006	22	2	2025-11-04 21:24:10.959427	2025-11-05 07:45:03.230835	\N	\N	f	\N	t	4	f
513	https://www.r4.com/inversion-para-todos/que-es-la-competencia-imperfecta-y-que-tipos-existen	112	2	2025-11-04 21:32:15.101311	2025-11-05 07:52:41.492698	\N	\N	f	\N	t	4	f
173	https://www.r4.com/fondos-de-inversion/fondos/ES0173130081	23	2	2025-11-04 21:24:13.647075	2025-11-05 07:45:05.549174	\N	\N	f	\N	t	4	f
174	https://www.r4.com/fondos-de-inversion/fondos/ES0173130016	23	2	2025-11-04 21:24:14.965696	2025-11-05 07:45:06.789473	\N	\N	f	\N	t	4	f
175	https://www.r4.com/fondos-de-inversion/fondos/ES0173130008	23	2	2025-11-04 21:24:16.246924	2025-11-05 07:45:08.362722	\N	\N	f	\N	t	4	f
176	https://www.r4.com/fondos-de-inversion/fondos/LU0348926287	23	2	2025-11-04 21:24:17.529323	2025-11-05 07:45:09.581498	\N	\N	f	\N	t	4	f
177	https://www.r4.com/fondos-de-inversion/fondos/LU1213836080	23	2	2025-11-04 21:24:18.807107	2025-11-05 07:45:10.833659	\N	\N	f	\N	t	4	f
178	https://www.r4.com/fondos-de-inversion/fondos/LU1951225553	23	2	2025-11-04 21:24:20.078163	2025-11-05 07:45:12.115319	\N	\N	f	\N	t	4	f
179	https://www.r4.com/fondos-de-inversion/fondos/LU0326422176	23	2	2025-11-04 21:24:21.496429	2025-11-05 07:45:13.365772	\N	\N	f	\N	t	4	f
180	https://www.r4.com/fondos-de-inversion/fondos/LU0273159177	23	2	2025-11-04 21:24:22.767138	2025-11-05 07:45:14.598707	\N	\N	f	\N	t	4	f
182	https://www.r4.com/fondos-de-inversion/fondos/ES0176954008	24	2	2025-11-04 21:24:25.280901	2025-11-05 07:45:17.115024	\N	\N	f	\N	t	4	f
183	https://www.r4.com/fondos-de-inversion/fondos/ES0173319007	24	2	2025-11-04 21:24:26.566606	2025-11-05 07:45:18.348733	\N	\N	f	\N	t	4	f
184	https://www.r4.com/fondos-de-inversion/fondos/ES0128522002	24	2	2025-11-04 21:24:27.863923	2025-11-05 07:45:19.540255	\N	\N	f	\N	t	4	f
185	https://www.r4.com/fondos-de-inversion/fondos/LU0243957825	24	2	2025-11-04 21:24:29.090978	2025-11-05 07:45:20.793266	\N	\N	f	\N	t	4	f
186	https://www.r4.com/fondos-de-inversion/fondos/LU0408877412	24	2	2025-11-04 21:24:30.328835	2025-11-05 07:45:22.027002	\N	\N	f	\N	t	4	f
187	https://www.r4.com/fondos-de-inversion/fondos/FI0008811997	24	2	2025-11-04 21:24:31.597322	2025-11-05 07:45:23.308645	\N	\N	f	\N	t	4	f
188	https://www.r4.com/fondos-de-inversion/fondos/IE00BDZRWZ54	24	2	2025-11-04 21:24:32.893989	2025-11-05 07:45:24.520755	\N	\N	f	\N	t	4	f
189	https://www.r4.com/fondos-de-inversion/fondos/ES0173372030	25	2	2025-11-04 21:24:34.22816	2025-11-05 07:45:25.799958	\N	\N	f	\N	t	4	f
190	https://www.r4.com/fondos-de-inversion/fondos/FR0011408764	25	2	2025-11-04 21:24:35.445374	2025-11-05 07:45:27.047363	\N	\N	f	\N	t	4	f
191	https://www.r4.com/fondos-de-inversion/fondos/LU0423950210	25	2	2025-11-04 21:24:36.653059	2025-11-05 07:45:28.302633	\N	\N	f	\N	t	4	f
192	https://www.r4.com/fondos-de-inversion/fondos/FR0010288316	25	2	2025-11-04 21:24:37.896036	2025-11-05 07:45:29.531802	\N	\N	f	\N	t	4	f
194	https://www.r4.com/fondos-de-inversion/fondos/ES0116848005	26	2	2025-11-04 21:24:40.402953	2025-11-05 07:45:32.001782	\N	\N	f	\N	t	4	f
195	https://www.r4.com/fondos-de-inversion/fondos/LU1694789451	26	2	2025-11-04 21:24:41.69941	2025-11-05 07:45:33.228762	\N	\N	f	\N	t	4	f
196	https://www.r4.com/fondos-de-inversion/fondos/IE00BLP5S460	26	2	2025-11-04 21:24:43.048119	2025-11-05 07:45:34.434067	\N	\N	f	\N	t	4	f
197	https://www.r4.com/fondos-de-inversion/fondos/ES0108207038	27	2	2025-11-04 21:24:44.331599	2025-11-05 07:45:35.722125	\N	\N	f	\N	t	4	f
198	https://www.r4.com/fondos-de-inversion/fondos/ES0173286008	27	2	2025-11-04 21:24:45.835335	2025-11-05 07:45:36.97798	\N	\N	f	\N	t	4	f
199	https://www.r4.com/fondos-de-inversion/fondos/ES0173052004	27	2	2025-11-04 21:24:47.120684	2025-11-05 07:45:38.286911	\N	\N	f	\N	t	4	f
200	https://www.r4.com/fondos-de-inversion/fondos/ES0173268006	27	2	2025-11-04 21:24:48.341223	2025-11-05 07:45:39.521093	\N	\N	f	\N	t	4	f
201	https://www.r4.com/fondos-de-inversion/fondos/ES0173321003	27	2	2025-11-04 21:24:49.6736	2025-11-05 07:45:40.732964	\N	\N	f	\N	t	4	f
202	https://www.r4.com/fondos-de-inversion/fondos/ES0108282007	27	2	2025-11-04 21:24:50.98275	2025-11-05 07:45:41.95769	\N	\N	f	\N	t	4	f
203	https://www.r4.com/fondos-de-inversion/fondos/ES0173311103	27	2	2025-11-04 21:24:52.304485	2025-11-05 07:45:43.145269	\N	\N	f	\N	t	4	f
205	https://www.r4.com/portal?TX=goto&FWD=FCH_FND&PAG=5&HOJA=2&COD_ISIN=ES0176956003&DIVI=EUR	28	2	2025-11-04 21:24:54.727158	2025-11-05 07:45:45.491801	\N	\N	f	\N	t	4	f
206	https://www.r4.com/portal?TX=goto&FWD=FCH_FND&PAG=5&HOJA=2&COD_ISIN=ES0173271000&DIVI=EUR	28	2	2025-11-04 21:24:55.84453	2025-11-05 07:45:46.591627	\N	\N	f	\N	t	4	f
207	https://www.r4.com/portal?TX=goto&FWD=FCH_FND&PAG=5&HOJA=2&COD_ISIN=ES0173859002&DIVI=EUR	28	2	2025-11-04 21:24:56.946106	2025-11-05 07:45:47.702181	\N	\N	f	\N	t	4	f
208	https://www.r4.com/fondos-de-inversion/fondos/ES0173270010	28	2	2025-11-04 21:24:58.078647	2025-11-05 07:45:48.885234	\N	\N	f	\N	t	4	f
209	https://www.r4.com/fondos-de-inversion/fondos/ES0176956003	28	2	2025-11-04 21:24:59.311493	2025-11-05 07:45:50.103809	\N	\N	f	\N	t	4	f
210	https://www.r4.com/fondos-de-inversion/fondos/ES0173271000	28	2	2025-11-04 21:25:00.548317	2025-11-05 07:45:52.770924	\N	\N	f	\N	t	4	f
211	https://www.r4.com/fondos-de-inversion/fondos/ES0173859002	28	2	2025-11-04 21:25:01.803969	2025-11-05 07:45:55.261938	\N	\N	f	\N	t	4	f
212	https://www.r4.com/fondos-de-inversion/fondos/ES0173053002	29	2	2025-11-04 21:25:03.135508	2025-11-05 07:45:56.455874	\N	\N	f	\N	t	4	f
213	https://www.r4.com/fondos-de-inversion/fondos/ES0173053010	29	2	2025-11-04 21:25:04.364272	2025-11-05 07:45:57.609198	\N	\N	f	\N	t	4	f
215	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=SEL	30	2	2025-11-04 21:25:06.805149	2025-11-05 07:45:59.946043	\N	\N	f	\N	t	4	f
216	https://www.r4.com/fondos-de-inversion/fondos/LU0568621618	30	2	2025-11-04 21:25:07.955612	2025-11-05 07:46:01.138654	\N	\N	f	\N	t	4	f
217	https://www.r4.com/fondos-de-inversion/fondos/FR0013314234	30	2	2025-11-04 21:25:09.218133	2025-11-05 07:46:02.335914	\N	\N	f	\N	t	4	f
218	https://www.r4.com/fondos-de-inversion/fondos/LU0970691076	30	2	2025-11-04 21:25:10.528116	2025-11-05 07:46:03.526885	\N	\N	f	\N	t	4	f
220	https://www.r4.com/fondos-de-inversion/fondos/LU0132601682	30	2	2025-11-04 21:25:13.034396	2025-11-05 07:46:05.955467	\N	\N	f	\N	t	4	f
221	https://www.r4.com/fondos-de-inversion/fondos/FR0007008750	30	2	2025-11-04 21:25:14.281583	2025-11-05 07:46:08.503885	\N	\N	f	\N	t	4	f
222	https://www.r4.com/fondos-de-inversion/fondos/BE0943877671	30	2	2025-11-04 21:25:15.64755	2025-11-05 07:46:09.681744	\N	\N	f	\N	t	4	f
223	https://www.r4.com/fondos-de-inversion/fondos/LU0251661756	30	2	2025-11-04 21:25:16.937466	2025-11-05 07:46:10.833637	\N	\N	f	\N	t	4	f
224	https://www.r4.com/fondos-de-inversion/fondos/LU0960403268	30	2	2025-11-04 21:25:18.220358	2025-11-05 07:46:12.031323	\N	\N	f	\N	t	4	f
225	https://www.r4.com/fondos-de-inversion/fondos/LU1299306321	30	2	2025-11-04 21:25:19.480222	2025-11-05 07:46:13.255345	\N	\N	f	\N	t	4	f
226	https://www.r4.com/fondos-de-inversion/fondos/LU0562247428	30	2	2025-11-04 21:25:20.758084	2025-11-05 07:46:14.486161	\N	\N	f	\N	t	4	f
227	https://www.r4.com/fondos-de-inversion/fondos/LU1585265066	30	2	2025-11-04 21:25:21.972628	2025-11-05 07:46:15.667286	\N	\N	f	\N	t	4	f
228	https://www.r4.com/fondos-de-inversion/fondos/LU0907927338	30	2	2025-11-04 21:25:23.232652	2025-11-05 07:46:16.885637	\N	\N	f	\N	t	4	f
229	https://www.r4.com/fondos-de-inversion/fondos/LU0569862609	30	2	2025-11-04 21:25:24.504663	2025-11-05 07:46:19.358733	\N	\N	f	\N	t	4	f
230	https://www.r4.com/fondos-de-inversion/fondos/LU1366712435	30	2	2025-11-04 21:25:25.774759	2025-11-05 07:46:20.622013	\N	\N	f	\N	t	4	f
704	https://www.r4.com/articulos-y-analisis/valores/3	428	3	2025-11-04 21:36:40.938339	2025-11-05 07:56:57.566492	\N	\N	f	\N	t	4	f
233	https://www.r4.com/fondos-de-inversion/fondos/LU0353647737	30	2	2025-11-04 21:25:30.864277	2025-11-05 07:46:24.197455	\N	\N	f	\N	t	4	f
234	https://www.r4.com/fondos-de-inversion/fondos/LU0289214628	30	2	2025-11-04 21:25:32.303583	2025-11-05 07:46:25.423168	\N	\N	f	\N	t	4	f
235	https://www.r4.com/fondos-de-inversion/fondos/LU1295551144	30	2	2025-11-04 21:25:33.523499	2025-11-05 07:46:26.634741	\N	\N	f	\N	t	4	f
236	https://www.r4.com/fondos-de-inversion/fondos/IE00BDGV0290	30	2	2025-11-04 21:25:36.249617	2025-11-05 07:46:27.829238	\N	\N	f	\N	t	4	f
237	https://www.r4.com/fondos-de-inversion/fondos/LU0119620416	30	2	2025-11-04 21:25:37.454895	2025-11-05 07:46:29.117962	\N	\N	f	\N	t	4	f
239	https://www.r4.com/fondos-de-inversion/fondos/LU1654173217	30	2	2025-11-04 21:25:40.10327	2025-11-05 07:46:31.652673	\N	\N	f	\N	t	4	f
240	https://www.r4.com/fondos-de-inversion/fondos/IE00B3XFBR64	30	2	2025-11-04 21:25:41.546173	2025-11-05 07:46:32.929906	\N	\N	f	\N	t	4	f
241	https://www.r4.com/fondos-de-inversion/fondos/IE00B19Z3920	30	2	2025-11-04 21:25:44.345733	2025-11-05 07:46:34.158186	\N	\N	f	\N	t	4	f
242	https://www.r4.com/fondos-de-inversion/fondos/LU0613075240	30	2	2025-11-04 21:25:47.013384	2025-11-05 07:46:35.40461	\N	\N	f	\N	t	4	f
243	https://www.r4.com/fondos-de-inversion/fondos/LU1599216113	30	2	2025-11-04 21:25:48.240554	2025-11-05 07:46:36.613099	\N	\N	f	\N	t	4	f
244	https://www.r4.com/fondos-de-inversion/fondos/LU0918140210	30	2	2025-11-04 21:25:49.669852	2025-11-05 07:46:37.828523	\N	\N	f	\N	t	4	f
245	https://www.r4.com/fondos-de-inversion/fondos/LU0329429897	30	2	2025-11-04 21:25:52.335769	2025-11-05 07:46:38.98679	\N	\N	f	\N	t	4	f
246	https://www.r4.com/fondos-de-inversion/fondos/BE6213829094	30	2	2025-11-04 21:25:54.934091	2025-11-05 07:46:40.227725	\N	\N	f	\N	t	4	f
247	https://www.r4.com/fondos-de-inversion/fondos/LU0171307068	30	2	2025-11-04 21:25:57.619972	2025-11-05 07:46:42.85253	\N	\N	f	\N	t	4	f
248	https://www.r4.com/fondos-de-inversion/fondos/LU0302296495	30	2	2025-11-04 21:25:58.83663	2025-11-05 07:46:44.25874	\N	\N	f	\N	t	4	f
250	https://www.r4.com/fondos-de-inversion/fondos/LU1919842267	30	2	2025-11-04 21:26:01.462212	2025-11-05 07:46:46.839402	\N	\N	f	\N	t	4	f
251	https://www.r4.com/fondos-de-inversion/fondos/IE00BZ18VZ93	30	2	2025-11-04 21:26:04.283991	2025-11-05 07:46:48.073996	\N	\N	f	\N	t	4	f
252	https://www.r4.com/fondos-de-inversion/fondos/LU2145461757	30	2	2025-11-04 21:26:06.86258	2025-11-05 07:46:50.635698	\N	\N	f	\N	t	4	f
253	https://www.r4.com/fondos-de-inversion/fondos/LU1245470593	30	2	2025-11-04 21:26:08.096147	2025-11-05 07:46:52.153276	\N	\N	f	\N	t	4	f
254	https://www.r4.com/fondos-de-inversion/fondos/FR0011253624	30	2	2025-11-04 21:26:09.349036	2025-11-05 07:46:54.733763	\N	\N	f	\N	t	4	f
255	https://www.r4.com/fondos-de-inversion/fondos/IE00BYV18N80	30	2	2025-11-04 21:26:10.592527	2025-11-05 07:46:55.972365	\N	\N	f	\N	t	4	f
256	https://www.r4.com/fondos-de-inversion/fondos/LU1006075656	30	2	2025-11-04 21:26:11.812883	2025-11-05 07:46:57.230332	\N	\N	f	\N	t	4	f
257	https://www.r4.com/fondos-de-inversion/fondos/LU0553169458	30	2	2025-11-04 21:26:14.379775	2025-11-05 07:46:58.466753	\N	\N	f	\N	t	4	f
258	https://www.r4.com/fondos-de-inversion/categorias/fondos-indexados	30	2	2025-11-04 21:26:15.625349	2025-11-05 07:46:59.723134	\N	\N	f	\N	t	4	f
260	https://www.r4.com/planes-de-pensiones/planes/F2266	31	2	2025-11-04 21:26:19.413273	2025-11-05 07:47:02.474168	\N	\N	f	\N	t	4	f
261	https://www.r4.com/planes-de-pensiones/planes/F2267	31	2	2025-11-04 21:26:20.655167	2025-11-05 07:47:03.68515	\N	\N	f	\N	t	4	f
263	https://www.r4.com/planes-de-pensiones/planes/F2123	31	2	2025-11-04 21:26:24.558085	2025-11-05 07:47:06.228632	\N	\N	f	\N	t	4	f
264	https://www.r4.com/planes-de-pensiones/planes/F0470	31	2	2025-11-04 21:26:25.845241	2025-11-05 07:47:07.46984	\N	\N	f	\N	t	4	f
265	https://www.r4.com/planes-de-pensiones/planes/F1498	31	2	2025-11-04 21:26:27.209474	2025-11-05 07:47:08.713972	\N	\N	f	\N	t	4	f
266	https://www.r4.com/planes-de-pensiones/planes/EP2	31	2	2025-11-04 21:26:30.004146	2025-11-05 07:47:10.002826	\N	\N	f	\N	t	4	f
267	https://www.r4.com/planes-de-pensiones/planes/F1466	31	2	2025-11-04 21:26:31.311269	2025-11-05 07:47:11.28136	\N	\N	f	\N	t	4	f
268	https://www.r4.com/planes-de-pensiones/planes/F0676	31	2	2025-11-04 21:26:32.72851	2025-11-05 07:47:12.544334	\N	\N	f	\N	t	4	f
269	https://www.r4.com/planes-de-pensiones/planes/F2098	31	2	2025-11-04 21:26:33.953879	2025-11-05 07:47:13.759088	\N	\N	f	\N	t	4	f
270	https://www.r4.com/planes-de-pensiones/planes/F2032	31	2	2025-11-04 21:26:35.199361	2025-11-05 07:47:14.996274	\N	\N	f	\N	t	4	f
271	https://www.r4.com/planes-de-pensiones/planes/F2099	31	2	2025-11-04 21:26:36.424509	2025-11-05 07:47:16.20811	\N	\N	f	\N	t	4	f
272	https://www.r4.com/planes-de-pensiones/planes/F2033	31	2	2025-11-04 21:26:37.652372	2025-11-05 07:47:17.41917	\N	\N	f	\N	t	4	f
274	https://www.r4.com/planes-de-pensiones/planes/F1606	31	2	2025-11-04 21:26:41.590924	2025-11-05 07:47:19.86873	\N	\N	f	\N	t	4	f
275	https://www.r4.com/planes-de-pensiones/planes/F2031	31	2	2025-11-04 21:26:44.109678	2025-11-05 07:47:21.154787	\N	\N	f	\N	t	4	f
276	https://www.r4.com/planes-de-pensiones/planes/F2015	31	2	2025-11-04 21:26:46.712951	2025-11-05 07:47:22.445326	\N	\N	f	\N	t	4	f
277	https://www.r4.com/planes-de-pensiones/planes/F2013	31	2	2025-11-04 21:26:47.992922	2025-11-05 07:47:23.650475	\N	\N	f	\N	t	4	f
278	https://www.r4.com/planes-de-pensiones/planes/F1467	31	2	2025-11-04 21:26:49.373369	2025-11-05 07:47:24.92193	\N	\N	f	\N	t	4	f
279	https://www.r4.com/planes-de-pensiones/planes/F1430	31	2	2025-11-04 21:26:50.910655	2025-11-05 07:47:26.246378	\N	\N	f	\N	t	4	f
280	https://www.r4.com/planes-de-pensiones/planes/F2233	31	2	2025-11-04 21:26:52.179299	2025-11-05 07:47:28.8985	\N	\N	f	\N	t	4	f
281	https://www.r4.com/planes-de-pensiones/planes/F1425	31	2	2025-11-04 21:26:54.743058	2025-11-05 07:47:30.153406	\N	\N	f	\N	t	4	f
282	https://www.r4.com/planes-de-pensiones/planes/EP4	31	2	2025-11-04 21:26:57.24435	2025-11-05 07:47:31.32522	\N	\N	f	\N	t	4	f
286	https://www.r4.com/planes-de-pensiones/categorias/planes-de-pensiones-perfilados	31	2	2025-11-04 21:27:02.720822	2025-11-05 07:47:36.099103	\N	\N	f	\N	t	4	f
288	https://www.r4.com/portal?TX=fondos&OPC=10&PAG=15&HOJA=2&SUB_HOJA=1&NOLEFT=null&NOCAB=null&NOBOTTOM=null&PLN=S	32	2	2025-11-04 21:27:05.086321	2025-11-05 07:47:38.462989	\N	\N	f	\N	t	4	f
289	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=F1425&DIVI=EUR&CBR=	32	2	2025-11-04 21:27:06.189534	2025-11-05 07:47:39.593391	\N	\N	f	\N	t	4	f
290	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=F1430&DIVI=EUR&CBR=	32	2	2025-11-04 21:27:07.310495	2025-11-05 07:47:40.746374	\N	\N	f	\N	t	4	f
291	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=F2233&DIVI=EUR&CBR=	32	2	2025-11-04 21:27:08.442868	2025-11-05 07:47:41.915689	\N	\N	f	\N	t	4	f
603	https://www.r4.com/que-necesitas/formacion/empezar-invertir/cuanto-dinero-necesito-para-invertir	303	3	2025-11-04 21:34:22.254702	2025-11-05 07:54:40.863395	\N	\N	f	\N	t	4	f
294	https://www.r4.com/que-necesitas/contacto	33	2	2025-11-04 21:27:11.841136	2025-11-05 07:47:45.445355	\N	\N	f	\N	t	4	f
300	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=NDQ	34	2	2025-11-04 21:27:19.487467	2025-11-05 07:47:52.527567	\N	\N	f	\N	t	4	f
301	https://r4.com/portal?fWD=CNT002&TX=goto&TP=1&DST=BSC	34	2	2025-11-04 21:27:20.60191	2025-11-05 07:47:53.753962	\N	\N	f	\N	t	4	f
307	https://www.r4.com/articulos-y-analisis/valores/telefonica-resultados-por-debajo-de-lo-previsto-a-partir-del-ebitda-deuda-neta-mas-elevada-de-lo-previsto-revisa-a-la-baja-la-prevision-de-fcf-2025e-y-mantiene-el-resto-de-los-objetivos-2025e	34	2	2025-11-04 21:27:28.0835	2025-11-05 07:48:00.869314	\N	\N	f	\N	t	4	f
308	https://www.r4.com/articulos-y-analisis/valores/corticeira-amorim-3t25-generando-caja-pese-al-complejo-entorno	34	2	2025-11-04 21:27:29.228608	2025-11-05 07:48:02.086034	\N	\N	f	\N	t	4	f
309	https://www.r4.com/articulos-y-analisis/valores/telefonica-cierre-de-la-venta-de-telefonica-ecuador	34	2	2025-11-04 21:27:30.381282	2025-11-05 07:48:03.235461	\N	\N	f	\N	t	4	f
310	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=ETF	35	2	2025-11-04 21:27:31.534149	2025-11-05 07:48:04.468671	\N	\N	f	\N	t	4	f
311	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=IE00B4L5Y983&MKT=MMI	35	2	2025-11-04 21:27:32.654228	2025-11-05 07:48:05.722308	\N	\N	f	\N	t	4	f
312	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=IE00B5BMR087&MKT=MMI	35	2	2025-11-04 21:27:33.782518	2025-11-05 07:48:06.914811	\N	\N	f	\N	t	4	f
313	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=IE000RHYOR04&MKT=MFR	35	2	2025-11-04 21:27:34.916176	2025-11-05 07:48:08.098636	\N	\N	f	\N	t	4	f
314	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=IE00BC7GZW19&MKT=MFR	35	2	2025-11-04 21:27:36.035603	2025-11-05 07:48:09.265973	\N	\N	f	\N	t	4	f
315	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=LU0380865021&MKT=MFR	35	2	2025-11-04 21:27:37.162528	2025-11-05 07:48:10.456835	\N	\N	f	\N	t	4	f
316	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=IE00BF16M727&MKT=MFR	35	2	2025-11-04 21:27:38.286348	2025-11-05 07:48:11.665674	\N	\N	f	\N	t	4	f
317	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=IE00BLCHJB90&MKT=MMI	35	2	2025-11-04 21:27:39.415519	2025-11-05 07:48:12.815313	\N	\N	f	\N	t	4	f
318	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=IE00BF4RFH31&MKT=MFR	35	2	2025-11-04 21:27:40.54528	2025-11-05 07:48:13.995454	\N	\N	f	\N	t	4	f
319	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=IE00BM67HM91&MKT=MFR	35	2	2025-11-04 21:27:41.666907	2025-11-05 07:48:15.197248	\N	\N	f	\N	t	4	f
320	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=IE00BM67HK77&MKT=MFR	35	2	2025-11-04 21:27:42.83671	2025-11-05 07:48:16.353516	\N	\N	f	\N	t	4	f
321	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=CH1199067674&MKT=MFR	35	2	2025-11-04 21:27:43.981827	2025-11-05 07:48:17.531665	\N	\N	f	\N	t	4	f
323	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=DE000A28M8D0&MKT=MFR	35	2	2025-11-04 21:27:46.225727	2025-11-05 07:48:19.856501	\N	\N	f	\N	t	4	f
324	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=DE000A3GPSP7&MKT=MFR	35	2	2025-11-04 21:27:47.360518	2025-11-05 07:48:21.020704	\N	\N	f	\N	t	4	f
325	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=GB00BJYDH394&MKT=MFR	35	2	2025-11-04 21:27:48.511607	2025-11-05 07:48:22.208792	\N	\N	f	\N	t	4	f
326	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=FR0010468983&MKT=MPA	35	2	2025-11-04 21:27:49.637685	2025-11-05 07:48:23.352768	\N	\N	f	\N	t	4	f
327	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US25461A8669&MKT=MMO	35	2	2025-11-04 21:27:50.763267	2025-11-05 07:48:24.531807	\N	\N	f	\N	t	4	f
328	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=IE00BLS09N40&MKT=MMI	35	2	2025-11-04 21:27:51.89103	2025-11-05 07:48:25.927021	\N	\N	f	\N	t	4	f
329	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=IE00B8HGT870&MKT=MMI	35	2	2025-11-04 21:27:53.003715	2025-11-05 07:48:27.484937	\N	\N	f	\N	t	4	f
330	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=LU0411078552&MKT=MFR	35	2	2025-11-04 21:27:54.159147	2025-11-05 07:48:28.684334	\N	\N	f	\N	t	4	f
331	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=FR0010424143&MKT=MPA	35	2	2025-11-04 21:27:55.294631	2025-11-05 07:48:29.85843	\N	\N	f	\N	t	4	f
332	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=JE00B78DPL57&MKT=MMI	35	2	2025-11-04 21:27:56.44303	2025-11-05 07:48:31.067659	\N	\N	f	\N	t	4	f
333	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=IE00B8KD3F05&MKT=MMI	35	2	2025-11-04 21:27:57.572878	2025-11-05 07:48:32.223554	\N	\N	f	\N	t	4	f
334	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=IE00BYTYHM11&MKT=MMI	35	2	2025-11-04 21:27:58.738314	2025-11-05 07:48:33.377345	\N	\N	f	\N	t	4	f
335	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=LU0322251520&MKT=MFR	35	2	2025-11-04 21:27:59.946228	2025-11-05 07:48:34.556585	\N	\N	f	\N	t	4	f
338	https://www.r4.com/content/rentabanco/r4/es/broker-online/productos-de-inversion/renta-fija	36	2	2025-11-04 21:28:03.53049	2025-11-05 07:48:38.278188	\N	\N	f	\N	t	4	f
339	https://www.r4.com/serviciosr4/productos-cotizados	38	2	2025-11-04 21:28:04.84593	2025-11-05 07:48:39.571841	\N	\N	f	\N	t	4	f
342	https://www.r4.com/go/main	41	2	2025-11-04 21:28:08.371604	2025-11-05 07:48:43.274241	\N	\N	f	\N	t	4	f
343	https://www.r4.com/goto/mapa-sitio	41	2	2025-11-04 21:28:09.65825	2025-11-05 07:48:45.270553	\N	\N	f	\N	t	4	f
344	https://www.r4.com/go/mark/comisiones09	41	2	2025-11-04 21:28:10.943299	2025-11-05 07:48:46.624541	\N	\N	f	\N	t	4	f
522	https://www.r4.com/articulos-y-analisis/noticias-renta4/fundacion-renta-4-colabora-con-fundacion-lacasa-kko-para-impulsar-la-educacion-y-el-desarrollo-en-costa-de-marfil	113	2	2025-11-04 21:32:29.025418	2025-11-05 07:52:57.359524	\N	\N	f	\N	t	4	f
346	https://www.r4.com/go/apertura/cuenta	41	2	2025-11-04 21:28:13.615009	2025-11-05 07:48:49.326475	\N	\N	f	\N	t	4	f
347	https://www.r4.com/go/apertura/15dias	41	2	2025-11-04 21:28:14.93523	2025-11-05 07:48:50.735679	\N	\N	f	\N	t	4	f
351	https://www.r4.com/go/bolsas/nacional	46	2	2025-11-04 21:28:20.118781	2025-11-05 07:48:56.149185	\N	\N	f	\N	t	4	f
352	https://www.r4.com/go/bolsas/internacional	46	2	2025-11-04 21:28:21.370899	2025-11-05 07:48:57.344736	\N	\N	f	\N	t	4	f
353	https://www.r4.com/go/etfs	46	2	2025-11-04 21:28:22.679229	2025-11-05 07:48:58.636157	\N	\N	f	\N	t	4	f
354	https://www.r4.com/go/cfds	46	2	2025-11-04 21:28:23.996524	2025-11-05 07:48:59.942534	\N	\N	f	\N	t	4	f
355	https://www.r4.com/go/warrants/renta4directo	46	2	2025-11-04 21:28:25.395497	2025-11-05 07:49:01.379741	\N	\N	f	\N	t	4	f
356	https://www.r4.com/go/derivados/futuros-sobre-acciones	46	2	2025-11-04 21:28:26.734228	2025-11-05 07:49:02.654717	\N	\N	f	\N	t	4	f
358	https://www.r4.com/go/derivados/futuros-sobre-divisas	46	2	2025-11-04 21:28:29.308445	2025-11-05 07:49:05.218399	\N	\N	f	\N	t	4	f
359	https://www.r4.com/go/derivados/futuros-sobre-renta-fija	46	2	2025-11-04 21:28:30.517911	2025-11-05 07:49:06.461511	\N	\N	f	\N	t	4	f
360	https://www.r4.com/go/fondos-planes	46	2	2025-11-04 21:28:31.728777	2025-11-05 07:49:07.777947	\N	\N	f	\N	t	4	f
361	https://www.r4.com/go/gestion	46	2	2025-11-04 21:28:32.970857	2025-11-05 07:49:09.030016	\N	\N	f	\N	t	4	f
362	https://www.r4.com/go/planes	46	2	2025-11-04 21:28:34.215952	2025-11-05 07:49:10.328544	\N	\N	f	\N	t	4	f
363	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=LTS	68	2	2025-11-04 21:28:35.482875	2025-11-05 07:49:11.524579	\N	\N	f	\N	t	4	f
364	https://r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=TRW&PLAZO=3a-5a&TIPO=TODOS	68	2	2025-11-04 21:28:36.670141	2025-11-05 07:49:12.70557	\N	\N	f	\N	t	4	f
365	https://r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=TRW&EMISOR=ES&PLAZO=3a-5a&TIPO=TODOS	68	2	2025-11-04 21:28:38.03953	2025-11-05 07:49:14.009	\N	\N	f	\N	t	4	f
366	https://www.r4.com/articulos-y-analisis/ideas/pausa-bce-relajacion-fed	68	2	2025-11-04 21:28:39.269724	2025-11-05 07:49:15.254584	\N	\N	f	\N	t	4	f
367	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=ASE	68	2	2025-11-04 21:28:40.479417	2025-11-05 07:49:16.558056	\N	\N	f	\N	t	4	f
368	https://www.r4.com/portal?TX=goto&FWD=LETRAS_EASY	69	2	2025-11-04 21:28:41.684665	2025-11-05 07:49:17.735978	\N	\N	f	\N	t	4	f
369	https://www.r4.com/serviciosr4/letras-easy	69	2	2025-11-04 21:28:42.892451	2025-11-05 07:49:18.914186	\N	\N	f	\N	t	4	f
371	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=TRW&PLAZO=3a-5a&TIPO=TODOS	70	2	2025-11-04 21:28:45.404917	2025-11-05 07:49:21.363613	\N	\N	f	\N	t	4	f
372	https://www.r4.com/broker-online/productos-de-inversion/renta-fija/invertir-bonos-renta-fija/rentabilidad-de-bonos-y-obligaciones-del-estado	70	2	2025-11-04 21:28:46.59532	2025-11-05 07:49:22.553617	\N	\N	f	\N	t	4	f
373	https://www.r4.com/broker-online/productos-de-inversion/renta-fija/invertir-bonos-renta-fija	71	2	2025-11-04 21:28:47.908485	2025-11-05 07:49:23.819255	\N	\N	f	\N	t	4	f
374	https://www.r4.com/broker-online/productos-de-inversion/renta-fija/letras-del-tesoro	72	2	2025-11-04 21:28:49.176793	2025-11-05 07:49:25.092843	\N	\N	f	\N	t	4	f
375	https://www.r4.com/content/rentabanco/r4/es/soluciones-easy/invertir-easy/plan-easy	79	2	2025-11-04 21:28:50.465716	2025-11-05 07:49:26.636618	\N	\N	f	\N	t	4	f
376	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=AGS&TIPOCARTERA=17	80	2	2025-11-04 21:28:51.736117	2025-11-05 07:49:27.90294	\N	\N	f	\N	t	4	f
377	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FCT	81	2	2025-11-04 21:28:52.903268	2025-11-05 07:49:29.08025	\N	\N	f	\N	t	4	f
378	https://www.r4.com/portal?TX=cuenta_fondo&OPC=1&PAG=6&HOJA=6	81	2	2025-11-04 21:28:54.114626	2025-11-05 07:49:30.257842	\N	\N	f	\N	t	4	f
379	https://www.r4.com/fondos-de-inversion/fondos/ES0173222003	81	2	2025-11-04 21:28:55.292804	2025-11-05 07:49:31.402959	\N	\N	f	\N	t	4	f
381	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=ES0176956003&DIVI=EUR&CBR=	82	2	2025-11-04 21:28:57.735899	2025-11-05 07:49:33.872986	\N	\N	f	\N	t	4	f
382	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=ES0173271000&DIVI=EUR&CBR=	82	2	2025-11-04 21:28:59.191218	2025-11-05 07:49:35.027224	\N	\N	f	\N	t	4	f
383	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=ES0173859002&DIVI=EUR&CBR=	82	2	2025-11-04 21:29:00.565342	2025-11-05 07:49:36.239756	\N	\N	f	\N	t	4	f
384	https://www.r4.com/articulos-y-analisis/informes-de-analisis/imparable-rally-bursatil-y-ahora-que	84	2	2025-11-04 21:29:01.723334	2025-11-05 07:49:37.441716	\N	\N	f	\N	t	4	f
385	https://www.r4.com/articulos-y-analisis/informes-de-analisis/tomas-de-beneficios-tras-resultados-de-palantir-y-menores-probabilidades-de-recortes-de-la-fed	84	2	2025-11-04 21:29:02.913923	2025-11-05 07:49:38.669917	\N	\N	f	\N	t	4	f
386	https://www.r4.com/articulos-y-analisis/tecnico/telefonica-la-caida-le-acerca-a-zonas-clave-entre-3-45-y-3-70-euros	84	2	2025-11-04 21:29:04.180763	2025-11-05 07:49:39.856475	\N	\N	f	\N	t	4	f
388	https://www.r4.com/articulos-y-analisis/cripto/correccion-y-tension-stablecoins	84	2	2025-11-04 21:29:06.720388	2025-11-05 07:49:42.275474	\N	\N	f	\N	t	4	f
389	https://www.r4.com/articulos-y-analisis/tecnico/el-ibex-ante-el-umbral-del-record-18-anos-despues	84	2	2025-11-04 21:29:07.975591	2025-11-05 07:49:43.517763	\N	\N	f	\N	t	4	f
390	https://www.r4.com/articulos-y-analisis/ideas/IA-deuda-publica-y-tipos-tres-titanes-obligados-a-entenderse	84	2	2025-11-04 21:29:09.155665	2025-11-05 07:49:44.709112	\N	\N	f	\N	t	4	f
391	https://www.r4.com/articulos-y-analisis/ideas/BBVA-y-Almirall-entran-en-nuestras-carteras	84	2	2025-11-04 21:29:10.364615	2025-11-05 07:49:45.952203	\N	\N	f	\N	t	4	f
392	https://www.r4.com/articulos-y-analisis/ideas/nuevos-fondos-s50-4T25	84	2	2025-11-04 21:29:11.608847	2025-11-05 07:49:47.142359	\N	\N	f	\N	t	4	f
393	https://www.r4.com/articulos-y-analisis/ideas/que-esta-pasando-con-bnp-paribas	84	2	2025-11-04 21:29:12.808994	2025-11-05 07:49:48.338043	\N	\N	f	\N	t	4	f
394	https://www.r4.com/articulos-y-analisis/ideas/la-paradoja-de-las-granolas	85	2	2025-11-04 21:29:14.042994	2025-11-05 07:49:49.534896	\N	\N	f	\N	t	4	f
395	https://www.r4.com/autor/javier-galan	85	2	2025-11-04 21:29:15.248562	2025-11-05 07:49:50.724854	\N	\N	f	\N	t	4	f
396	https://www.r4.com/articulos-y-analisis/ideas/consumo-basico-oportunidad-caida	85	2	2025-11-04 21:29:16.450108	2025-11-05 07:49:51.94455	\N	\N	f	\N	t	4	f
397	https://www.r4.com/autor/david-cabeza	85	2	2025-11-04 21:29:17.689725	2025-11-05 07:49:53.112458	\N	\N	f	\N	t	4	f
398	https://www.r4.com/articulos-y-analisis/ideas/navegando-boom-tecnologico-invertir-sin-sobrevaloracion	85	2	2025-11-04 21:29:18.925572	2025-11-05 07:49:54.31329	\N	\N	f	\N	t	4	f
399	https://www.r4.com/autor/diego-santo-domingo	85	2	2025-11-04 21:29:20.168196	2025-11-05 07:49:55.569903	\N	\N	f	\N	t	4	f
400	https://www.r4.com/articulos-y-analisis/ideas/la-cadena-de-valor-de-la-ia	85	2	2025-11-04 21:29:21.386538	2025-11-05 07:49:56.841048	\N	\N	f	\N	t	4	f
552	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0124244E34	130	3	2025-11-04 21:33:09.873511	2025-11-05 07:53:36.498472	\N	\N	f	\N	t	4	f
564	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/invierte-en-las-mejores-companias-de-la-economia-mas-dinamica	172	3	2025-11-04 21:33:28.729485	2025-11-05 07:53:52.176442	\N	\N	f	\N	t	4	f
403	https://www.r4.com/articulos-y-analisis/ideas/2	85	2	2025-11-04 21:29:26.272866	2025-11-05 07:50:01.422373	\N	\N	f	\N	t	4	f
404	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-circulo-virtuoso-de-las-tecnologicas-sostiene-a-las-bolsas-pero-la-liquidez-ayuda	86	2	2025-11-04 21:29:27.651453	2025-11-05 07:50:02.661562	\N	\N	f	\N	t	4	f
405	https://www.r4.com/autor/juan-carlos-ureta	86	2	2025-11-04 21:29:28.940716	2025-11-05 07:50:03.921521	\N	\N	f	\N	t	4	f
406	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-el-curioso-paralelismo-del-nikkei-y-alphabet	86	2	2025-11-04 21:29:30.087112	2025-11-05 07:50:05.147437	\N	\N	f	\N	t	4	f
407	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/quo-vadis-europa	86	2	2025-11-04 21:29:31.311945	2025-11-05 07:50:06.340519	\N	\N	f	\N	t	4	f
408	https://www.r4.com/autor/jesus-sanchez-quinones	86	2	2025-11-04 21:29:32.476044	2025-11-05 07:50:07.543511	\N	\N	f	\N	t	4	f
409	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/las-preguntas-son-las-mismas-pero-cambian-las-respuestas	86	2	2025-11-04 21:29:34.826959	2025-11-05 07:50:08.74613	\N	\N	f	\N	t	4	f
410	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-apple-toma-el-relevo	86	2	2025-11-04 21:29:36.000893	2025-11-05 07:50:09.952556	\N	\N	f	\N	t	4	f
411	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/por-que-china-necesita-exportar	86	2	2025-11-04 21:29:37.173239	2025-11-05 07:50:11.182927	\N	\N	f	\N	t	4	f
413	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-el-lujo-pide-paso-a-la-defensa-en-europa	86	2	2025-11-04 21:29:41.899593	2025-11-05 07:50:13.641015	\N	\N	f	\N	t	4	f
414	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/conclusiones-del-efimero-crash-en-las-criptomonedas	86	2	2025-11-04 21:29:44.109544	2025-11-05 07:50:14.883442	\N	\N	f	\N	t	4	f
415	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/las-bolsas-entran-en-la-circularidad-con-amenaza-de-correccion	86	2	2025-11-04 21:29:45.283128	2025-11-05 07:50:16.134575	\N	\N	f	\N	t	4	f
416	https://www.r4.com/articulos-y-analisis/mercados/2	86	2	2025-11-04 21:29:46.454662	2025-11-05 07:50:17.365763	\N	\N	f	\N	t	4	f
417	https://www.r4.com/autor/ivan-san-felix	87	2	2025-11-04 21:29:48.561371	2025-11-05 07:50:19.449767	\N	\N	f	\N	t	4	f
418	https://www.r4.com/autor/pablo-fernandez	87	2	2025-11-04 21:29:49.754386	2025-11-05 07:50:20.650551	\N	\N	f	\N	t	4	f
419	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-previo-3t-25-se-abre-paso-a-un-mejor-entorno-en-europa	87	2	2025-11-04 21:29:50.938318	2025-11-05 07:50:21.87369	\N	\N	f	\N	t	4	f
420	https://www.r4.com/articulos-y-analisis/valores/acerinox-3t25-por-debajo-de-lo-esperado-consenso-debera-rebajar-estimaciones	87	2	2025-11-04 21:29:52.099307	2025-11-05 07:50:23.134439	\N	\N	f	\N	t	4	f
421	https://www.r4.com/autor/cesar-sanchez	87	2	2025-11-04 21:29:53.326959	2025-11-05 07:50:24.344927	\N	\N	f	\N	t	4	f
422	https://www.r4.com/articulos-y-analisis/valores/tubacex-3t25-resultados-que-muestran-la-debilidad-temporal-del-sector	87	2	2025-11-04 21:29:54.495332	2025-11-05 07:50:25.525973	\N	\N	f	\N	t	4	f
423	https://www.r4.com/articulos-y-analisis/valores/melia-hoteles-3t-25-resultados-alineados-con-las-previsiones-prevision-a-final-de-ano-sin-cambios	87	2	2025-11-04 21:29:56.801157	2025-11-05 07:50:26.719744	\N	\N	f	\N	t	4	f
424	https://www.r4.com/articulos-y-analisis/valores/unicaja-3t25-mejoran-ligeramente-guia-margen-de-intereses-y-coste-de-riesgo	87	2	2025-11-04 21:29:59.104405	2025-11-05 07:50:28.996971	\N	\N	f	\N	t	4	f
425	https://www.r4.com/autor/nuria-alvarez	87	2	2025-11-04 21:30:00.288133	2025-11-05 07:50:31.368724	\N	\N	f	\N	t	4	f
426	https://www.r4.com/articulos-y-analisis/valores/seresco-1s25-cumpliendo-con-el-guion-para-alcanzar-los-objetivos-de-2025	87	2	2025-11-04 21:30:01.466355	2025-11-05 07:50:32.589179	\N	\N	f	\N	t	4	f
427	https://www.r4.com/autor/eduardo-imedio	87	2	2025-11-04 21:30:03.706888	2025-11-05 07:50:34.94934	\N	\N	f	\N	t	4	f
428	https://www.r4.com/articulos-y-analisis/valores/2	87	2	2025-11-04 21:30:04.876264	2025-11-05 07:50:36.168287	\N	\N	f	\N	t	4	f
429	https://www.r4.com/articulos-y-analisis/tecnico/ideas-corto-plazo-19-alcista-moncler	88	2	2025-11-04 21:30:07.069752	2025-11-05 07:50:37.371252	\N	\N	f	\N	t	4	f
430	https://www.r4.com/articulos-y-analisis/tecnico/estrategia-rupturas-trimestrales-actualizacion-entra-arcelormittal	88	2	2025-11-04 21:30:08.229549	2025-11-05 07:50:38.595993	\N	\N	f	\N	t	4	f
431	https://www.r4.com/autor/eduardo-faus	88	2	2025-11-04 21:30:09.380656	2025-11-05 07:50:39.781916	\N	\N	f	\N	t	4	f
433	https://www.r4.com/articulos-y-analisis/tecnico/burbuja-ia-2025-vs-burbuja-tecnologica-ano-2000	88	2	2025-11-04 21:30:11.792321	2025-11-05 07:50:42.21953	\N	\N	f	\N	t	4	f
434	https://www.r4.com/articulos-y-analisis/tecnico/datos-confrontados-atencion-a-los-puntos-claves-del-s-p500	88	2	2025-11-04 21:30:12.990457	2025-11-05 07:50:43.412432	\N	\N	f	\N	t	4	f
435	https://www.r4.com/articulos-y-analisis/tecnico/cual-es-el-valor-oculto-de-tesla	88	2	2025-11-04 21:30:14.167933	2025-11-05 07:50:44.632226	\N	\N	f	\N	t	4	f
436	https://www.r4.com/articulos-y-analisis/tecnico/el-cambio-de-tendencia-en-solaria-es-cada-mes-mas-real	88	2	2025-11-04 21:30:15.361703	2025-11-05 07:50:45.88126	\N	\N	f	\N	t	4	f
437	https://www.r4.com/articulos-y-analisis/tecnico/energia-proxima-megatendencia	88	2	2025-11-04 21:30:16.617182	2025-11-05 07:50:47.113348	\N	\N	f	\N	t	4	f
438	https://www.r4.com/articulos-y-analisis/tecnico/valeo-rompe-al-alza-un-rango-de-16-meses	88	2	2025-11-04 21:30:17.814117	2025-11-05 07:50:49.244733	\N	\N	f	\N	t	4	f
439	https://www.r4.com/articulos-y-analisis/tecnico/senal-de-compra-de-corto-plazo-en-sap-que-presenta-un-decalaje-vs-dax	88	2	2025-11-04 21:30:19.030446	2025-11-05 07:50:50.456641	\N	\N	f	\N	t	4	f
440	https://www.r4.com/articulos-y-analisis/tecnico/el-ibex-mejora-los-5-ultimos-anos-del-dax-el-nasdaq-vuelve-a-mejorar-al-s-p500	88	2	2025-11-04 21:30:20.201548	2025-11-05 07:50:51.699658	\N	\N	f	\N	t	4	f
441	https://www.r4.com/articulos-y-analisis/tecnico/2	88	2	2025-11-04 21:30:22.513763	2025-11-05 07:50:53.938291	\N	\N	f	\N	t	4	f
442	https://www.r4.com/articulos-y-analisis/ideas/multigestora-cartera-tras-verano	89	2	2025-11-04 21:30:23.673403	2025-11-05 07:50:56.113769	\N	\N	f	\N	t	4	f
443	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-cripto-a-cierre-de-octubre-de-2025	89	2	2025-11-04 21:30:25.874901	2025-11-05 07:50:57.319681	\N	\N	f	\N	t	4	f
444	https://www.r4.com/autor/javier-pineda	89	2	2025-11-04 21:30:27.053583	2025-11-05 07:50:58.500846	\N	\N	f	\N	t	4	f
445	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-activos-globales-a-cierre-de-octubre-de-2025	89	2	2025-11-04 21:30:28.261495	2025-11-05 07:50:59.698295	\N	\N	f	\N	t	4	f
446	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-alpha-global-a-cierre-de-octubre-de-2025	89	2	2025-11-04 21:30:29.439185	2025-11-05 07:51:00.936276	\N	\N	f	\N	t	4	f
447	https://www.r4.com/autor/alberto-espelosin	89	2	2025-11-04 21:30:30.658234	2025-11-05 07:51:02.229989	\N	\N	f	\N	t	4	f
449	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-cripto-a-cierre-de-septiembre-de-2025	89	2	2025-11-04 21:30:35.258282	2025-11-05 07:51:05.722247	\N	\N	f	\N	t	4	f
482	https://www.r4.com/articulos-y-analisis/ideas/invierte-al-mismo-tiempo-que-ahorras	106	2	2025-11-04 21:31:30.685131	2025-11-05 07:51:59.132926	\N	\N	f	\N	t	4	f
488	https://www.r4.com/normativa/normativa-psd2	108	2	2025-11-04 21:31:39.822547	2025-11-05 07:52:07.579188	\N	\N	f	\N	t	4	f
495	https://www.r4.com/academiar4/buenos-habitos-de-ahorro	109	2	2025-11-04 21:31:50.087507	2025-11-05 07:52:16.84354	\N	\N	f	\N	t	4	f
498	https://www.r4.com/serviciosr4/boletin-diario-fundamental	110	2	2025-11-04 21:31:54.3465	2025-11-05 07:52:20.492565	\N	\N	f	\N	t	4	f
501	https://www.r4.com/serviciosr4/como-funciona-bolsa	110	2	2025-11-04 21:31:57.986867	2025-11-05 07:52:24.282092	\N	\N	f	\N	t	4	f
502	https://www.r4.com/serviciosr4/como-funciona-un-plan-de-pensiones-guia-gratis	110	2	2025-11-04 21:31:59.351242	2025-11-05 07:52:25.471664	\N	\N	f	\N	t	4	f
503	https://www.r4.com/serviciosr4/que-es-fondo-de-inversion-guia-gratis	110	2	2025-11-04 21:32:00.763769	2025-11-05 07:52:26.685632	\N	\N	f	\N	t	4	f
504	https://www.r4.com/serviciosr4/incertidumbre	110	2	2025-11-04 21:32:02.321099	2025-11-05 07:52:27.88776	\N	\N	f	\N	t	4	f
1031	https://r4.com/content/rentabanco/r4/es/serviciosr4/formacion/empezar-invertir	587	4	2025-11-04 21:45:05.05645	2025-11-05 08:05:34.735448	\N	\N	f	\N	t	4	f
451	https://www.r4.com/autor/alejandro-varela	89	2	2025-11-04 21:30:38.856714	2025-11-05 07:51:09.076744	\N	\N	f	\N	t	4	f
452	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-global-dynamic-fi-a-cierre-de-septiembre-de-2025	89	2	2025-11-04 21:30:40.119685	2025-11-05 07:51:10.306978	\N	\N	f	\N	t	4	f
454	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-megatendencias-salud-a-cierre-de-septiembre-de-2025	89	2	2025-11-04 21:30:43.65382	2025-11-05 07:51:14.961516	\N	\N	f	\N	t	4	f
455	https://www.r4.com/autor/elena-rico	89	2	2025-11-04 21:30:45.837948	2025-11-05 07:51:17.128231	\N	\N	f	\N	t	4	f
456	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-pegasus-a-cierre-de-septiembre-de-2025	89	2	2025-11-04 21:30:46.973914	2025-11-05 07:51:18.331703	\N	\N	f	\N	t	4	f
457	https://www.r4.com/autor/miguel-jimenez	89	2	2025-11-04 21:30:49.359979	2025-11-05 07:51:19.538587	\N	\N	f	\N	t	4	f
458	https://www.r4.com/articulos-y-analisis/fondos/2	89	2	2025-11-04 21:30:50.717256	2025-11-05 07:51:20.787728	\N	\N	f	\N	t	4	f
459	https://www.r4.com/articulos-y-analisis/cripto/powell-pierde-pulso-regulacion-ritmo	90	2	2025-11-04 21:30:51.877552	2025-11-05 07:51:22.012911	\N	\N	f	\N	t	4	f
460	https://www.r4.com/articulos-y-analisis/cripto/ethereum-toma-el-centro-del-escenario-en-un-septiembre-de-cambios	90	2	2025-11-04 21:30:53.100496	2025-11-05 07:51:23.232841	\N	\N	f	\N	t	4	f
461	https://www.r4.com/articulos-y-analisis/cripto/red-september-a-la-vuelta-de-la-esquina	90	2	2025-11-04 21:30:55.342761	2025-11-05 07:51:24.440406	\N	\N	f	\N	t	4	f
462	https://www.r4.com/articulos-y-analisis/cripto/record-ethereum-whale-sacude-mercado	90	2	2025-11-04 21:30:57.615607	2025-11-05 07:51:25.636168	\N	\N	f	\N	t	4	f
463	https://www.r4.com/articulos-y-analisis/cripto/fed-pone-fin-a-supervision-sobre-cripto	90	2	2025-11-04 21:30:59.766754	2025-11-05 07:51:27.706831	\N	\N	f	\N	t	4	f
464	https://www.r4.com/articulos-y-analisis/cripto/cripto-supera-los-4-billones-pese-a-la-volatilidad	90	2	2025-11-04 21:31:01.843576	2025-11-05 07:51:29.839964	\N	\N	f	\N	t	4	f
465	https://www.r4.com/articulos-y-analisis/cripto/bitcoin-consolida-politica-capital-institucional-alinean	90	2	2025-11-04 21:31:04.062627	2025-11-05 07:51:32.267169	\N	\N	f	\N	t	4	f
466	https://www.r4.com/articulos-y-analisis/cripto/10-anos-ethereum-de-experimento-acorazon-financiero-descentralizado	90	2	2025-11-04 21:31:05.20671	2025-11-05 07:51:34.563126	\N	\N	f	\N	t	4	f
467	https://www.r4.com/articulos-y-analisis/cripto/crypto-week-eeuu-se-pone-las-botas	90	2	2025-11-04 21:31:07.436672	2025-11-05 07:51:36.870005	\N	\N	f	\N	t	4	f
468	https://www.r4.com/articulos-y-analisis/cripto/2	90	2	2025-11-04 21:31:09.901671	2025-11-05 07:51:39.038969	\N	\N	f	\N	t	4	f
469	https://www.r4.com/content/rentabanco/r4/es/normativa/politica-cookies	92	2	2025-11-04 21:31:11.959531	2025-11-05 07:51:41.124014	\N	\N	f	\N	t	4	f
470	https://www.r4.com/portal?TX=goto&FWD=COMIS_TOTAL&PAG=99	93	2	2025-11-04 21:31:13.254521	2025-11-05 07:51:42.3297	\N	\N	f	\N	t	4	f
471	https://www.r4.com/portal?TX=goto&FWD=COMIS_XRFX&PAG=99	93	2	2025-11-04 21:31:14.987631	2025-11-05 07:51:43.441776	\N	\N	f	\N	t	4	f
472	https://www.r4.com/portal?TX=goto&FWD=COMIS_CFD&PAG=99	93	2	2025-11-04 21:31:16.157752	2025-11-05 07:51:45.148013	\N	\N	f	\N	t	4	f
473	https://www.r4.com/new?TX=goto&FWD=APERTURA-CUENTA&PORTLET=APE001	96	2	2025-11-04 21:31:18.048077	2025-11-05 07:51:47.57452	\N	\N	f	\N	t	4	f
474	https://www.r4.com/portal?TX=extractos&OPC=RECOM_ASE&PAG=6	100	2	2025-11-04 21:31:19.264486	2025-11-05 07:51:48.7928	\N	\N	f	\N	t	4	f
475	https://www.r4.com/asesoramiento/asesoramiento-personalizado	100	2	2025-11-04 21:31:20.384225	2025-11-05 07:51:49.928808	\N	\N	f	\N	t	4	f
477	https://www.r4.com/portal?TX=goto&FWD=CONTACTAR_CALL	102	2	2025-11-04 21:31:24.591322	2025-11-05 07:51:53.202543	\N	\N	f	\N	t	4	f
478	https://r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=TRL	105	2	2025-11-04 21:31:25.698573	2025-11-05 07:51:54.319051	\N	\N	f	\N	t	4	f
479	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=GRI	105	2	2025-11-04 21:31:26.900296	2025-11-05 07:51:55.604441	\N	\N	f	\N	t	4	f
480	https://www.r4.com/serviciosr4/boletin-analisis-mercados-financieros	105	2	2025-11-04 21:31:28.042555	2025-11-05 07:51:56.773987	\N	\N	f	\N	t	4	f
481	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=AHO	106	2	2025-11-04 21:31:29.537621	2025-11-05 07:51:57.950012	\N	\N	f	\N	t	4	f
966	https://www.r4.com/articulos-y-analisis/valores/dominion-3t25-la-normalizacion-de-margenes-y-el-retraso-en-proyectos-impacta-las-cifras	551	4	2025-11-04 21:43:33.983604	2025-11-05 08:04:04.241261	\N	\N	f	\N	t	4	f
507	https://www.r4.com/inversion-para-todos/category/curiosidades-financieras	112	2	2025-11-04 21:32:05.997058	2025-11-05 07:52:31.714954	\N	\N	f	\N	t	4	f
508	https://www.r4.com/inversion-para-todos/category/invertir-tus-ahorros	112	2	2025-11-04 21:32:07.51155	2025-11-05 07:52:33.258125	\N	\N	f	\N	t	4	f
509	https://www.r4.com/inversion-para-todos/category/invertir-en-ti	112	2	2025-11-04 21:32:09.016202	2025-11-05 07:52:34.873411	\N	\N	f	\N	t	4	f
510	https://www.r4.com/inversion-para-todos/descubre-el-dca-o-dollar-cost-averaging-como-metodo-de-inversion	112	2	2025-11-04 21:32:10.596638	2025-11-05 07:52:36.642502	\N	\N	f	\N	t	4	f
511	https://www.r4.com/inversion-para-todos/etfs-vs-fondos-indexados-conoce-sus-diferencias	112	2	2025-11-04 21:32:12.023682	2025-11-05 07:52:38.27409	\N	\N	f	\N	t	4	f
512	https://www.r4.com/inversion-para-todos/que-son-ordenes-stop-loss	112	2	2025-11-04 21:32:13.597094	2025-11-05 07:52:39.928214	\N	\N	f	\N	t	4	f
514	https://www.r4.com/inversion-para-todos/declaracion-renta-inversiones	112	2	2025-11-04 21:32:16.854376	2025-11-05 07:52:43.016738	\N	\N	f	\N	t	4	f
515	https://www.r4.com/inversion-para-todos/conoce-en-que-consiste-el-ter-de-un-fondo-de-inversion	112	2	2025-11-04 21:32:18.432834	2025-11-05 07:52:45.051355	\N	\N	f	\N	t	4	f
516	https://www.r4.com/inversion-para-todos/inversion-sostenible-en-que-consiste-y-como-hacerlo	112	2	2025-11-04 21:32:20.06883	2025-11-05 07:52:46.950725	\N	\N	f	\N	t	4	f
517	https://www.r4.com/inversion-para-todos/como-usar-la-inteligencia-artificial-para-invertir-en-bolsa	112	2	2025-11-04 21:32:21.560157	2025-11-05 07:52:48.642811	\N	\N	f	\N	t	4	f
518	https://www.r4.com/inversion-para-todos/etfs-o-acciones-que-opcion-es-mejor-para-invertir	112	2	2025-11-04 21:32:23.049582	2025-11-05 07:52:50.19915	\N	\N	f	\N	t	4	f
519	https://www.r4.com/inversion-para-todos/sabes-que-es-la-hiperinflacion-y-como-afecta-a-tus-ahorros	112	2	2025-11-04 21:32:24.530855	2025-11-05 07:52:52.444626	\N	\N	f	\N	t	4	f
520	https://www.r4.com/inversion-para-todos/conoce-las-diferencias-de-la-capitalizacion-simple-y-compuesta	112	2	2025-11-04 21:32:26.004471	2025-11-05 07:52:53.963109	\N	\N	f	\N	t	4	f
521	https://www.r4.com/inversion-para-todos/cuando-hay-que-vender-los-fondos-de-inversion	112	2	2025-11-04 21:32:27.500047	2025-11-05 07:52:55.807474	\N	\N	f	\N	t	4	f
523	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-banco-obtiene-un-beneficio-neto-de-30-8-millones-de-euros-durante-los-primeros-9-meses-un-31-8-mas-que-en-el-mismo-periodo-de-2024	113	2	2025-11-04 21:32:30.260152	2025-11-05 07:52:58.591463	\N	\N	f	\N	t	4	f
524	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-gestora-analiza-el-futuro-de-la-inversion-ia-deuda-y-tipos-de-interes-los-tres-titanes-obligados-a-entenderse	113	2	2025-11-04 21:32:31.54551	2025-11-05 07:52:59.817919	\N	\N	f	\N	t	4	f
525	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-renta-fija-euro-excelencia-reconocida-con-5-estrellas-morningstar	113	2	2025-11-04 21:32:32.830542	2025-11-05 07:53:01.028697	\N	\N	f	\N	t	4	f
526	https://www.r4.com/articulos-y-analisis/noticias-renta4/la-fundacion-renta-4-impulsa-oportunidades-de-futuro-en-kenia-junto-a-la-ong-things-happen	113	2	2025-11-04 21:32:34.089607	2025-11-05 07:53:02.240718	\N	\N	f	\N	t	4	f
527	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-gestora-lanza-el-primer-fondo-de-credito-alternativo-de-acceso-para-inversores-minoristas-en-espana	113	2	2025-11-04 21:32:36.345736	2025-11-05 07:53:03.427348	\N	\N	f	\N	t	4	f
528	https://www.r4.com/articulos-y-analisis/noticias-renta4/la-fundacion-espadafor-ganadora-de-las-ayudas-de-la-fundacion-renta-4-firma-un-acuerdo-de-colaboracion-en-granada	113	2	2025-11-04 21:32:37.59373	2025-11-05 07:53:04.674344	\N	\N	f	\N	t	4	f
529	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-banco-refuerza-su-equipo-directivo-con-la-incorporacion-de-diego-abaitua-como-director-de-banca-privada-y-wealth	113	2	2025-11-04 21:32:39.943086	2025-11-05 07:53:05.87299	\N	\N	f	\N	t	4	f
530	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-se-une-a-la-fundacion-numen-para-hacer-realidad-el-aula-de-los-suenos	113	2	2025-11-04 21:32:41.264063	2025-11-05 07:53:07.070668	\N	\N	f	\N	t	4	f
531	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-gestora-lanza-el-primer-fondo-de-credito-alternativo-tambien-accesible-para-inversores-minoristas-en-espana	113	2	2025-11-04 21:32:43.413288	2025-11-05 07:53:08.314924	\N	\N	f	\N	t	4	f
532	https://www.r4.com/articulos-y-analisis/area-prensa/2	113	2	2025-11-04 21:32:44.631806	2025-11-05 07:53:09.543801	\N	\N	f	\N	t	4	f
533	https://www.r4.com/conferencias/ahorrador-a-inversor	114	2	2025-11-04 21:32:45.881764	2025-11-05 07:53:10.828698	\N	\N	f	\N	t	4	f
534	https://www.r4.com/politicas/politica-privacidad	114	2	2025-11-04 21:32:47.031274	2025-11-05 07:53:12.010618	\N	\N	f	\N	t	4	f
537	https://www.r4.com/que-necesitas/compromiso-social/inversion-sostenible	115	2	2025-11-04 21:32:50.671874	2025-11-05 07:53:15.756993	\N	\N	f	\N	t	4	f
538	https://www.r4.com/content/rentabanco/r4/es/normativa	115	2	2025-11-04 21:32:51.887628	2025-11-05 07:53:16.981977	\N	\N	f	\N	t	4	f
539	https://www.r4.com/portal?TX=goto&FWD=CONTACTAR	117	2	2025-11-04 21:32:53.104328	2025-11-05 07:53:18.226997	\N	\N	f	\N	t	4	f
540	http://www.r4.com	118	2	2025-11-04 21:32:54.243294	2025-11-05 07:53:19.329241	\N	\N	f	\N	t	4	f
543	https://www.r4.com/portal?TX=goto&FWD=MAIN10&PAG=6	121	3	2025-11-04 21:32:57.990572	2025-11-05 07:53:22.985423	\N	\N	f	\N	t	4	f
544	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0113211835	124	3	2025-11-04 21:32:59.12289	2025-11-05 07:53:24.129853	\N	\N	f	\N	t	4	f
545	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0130960018	125	3	2025-11-04 21:33:00.325785	2025-11-05 07:53:26.3965	\N	\N	f	\N	t	4	f
546	https://www.r4.com/autor/angel-perez	125	3	2025-11-04 21:33:01.547078	2025-11-05 07:53:28.541983	\N	\N	f	\N	t	4	f
547	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0130670112	126	3	2025-11-04 21:33:02.720658	2025-11-05 07:53:29.983749	\N	\N	f	\N	t	4	f
548	https://www.r4.com/articulos-y-analisis/valores.MCO%2BNL0015001FS8	127	3	2025-11-04 21:33:04.834382	2025-11-05 07:53:31.526971	\N	\N	f	\N	t	4	f
549	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0148396007	128	3	2025-11-04 21:33:06.082855	2025-11-05 07:53:32.758395	\N	\N	f	\N	t	4	f
550	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0157261019	129	3	2025-11-04 21:33:07.374861	2025-11-05 07:53:34.011124	\N	\N	f	\N	t	4	f
551	https://www.r4.com/autor/alvaro-aristegui	129	3	2025-11-04 21:33:08.668117	2025-11-05 07:53:35.260951	\N	\N	f	\N	t	4	f
553	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0182870214	131	3	2025-11-04 21:33:11.145294	2025-11-05 07:53:37.731637	\N	\N	f	\N	t	4	f
554	https://www.r4.com/articulos-y-analisis/valores.MCO%2BLU1598757687	133	3	2025-11-04 21:33:13.393379	2025-11-05 07:53:38.996996	\N	\N	f	\N	t	4	f
1032	https://r4.com/politicas/politica-privacidad	594	4	2025-11-04 21:45:06.313699	2025-11-05 08:05:36.036922	\N	\N	f	\N	t	4	f
557	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0177542018	138	3	2025-11-04 21:33:18.72259	2025-11-05 07:53:42.671549	\N	\N	f	\N	t	4	f
558	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0105025003	140	3	2025-11-04 21:33:19.945994	2025-11-05 07:53:43.891411	\N	\N	f	\N	t	4	f
559	https://www.r4.com/autor/javier-diaz	140	3	2025-11-04 21:33:21.909525	2025-11-05 07:53:45.142262	\N	\N	f	\N	t	4	f
560	https://www.r4.com/serviciosr4/guia-fiscalidad	146	3	2025-11-04 21:33:23.084148	2025-11-05 07:53:46.342826	\N	\N	f	\N	t	4	f
563	https://www.r4.com/fondos-de-inversion/servicios/ahorro-periodico?int=propia:massostenible:login	154	3	2025-11-04 21:33:26.671167	2025-11-05 07:53:50.03855	\N	\N	f	\N	t	4	f
565	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/renta-4-renta-fija-que-oportunidades-encontramos-en-la-renta-fija-ante-la-bajada-de-los-tipos-de-interes	172	3	2025-11-04 21:33:29.992099	2025-11-05 07:53:53.364705	\N	\N	f	\N	t	4	f
760	https://www.r4.com/complaint/form	487	3	2025-11-04 21:38:03.523702	2025-11-05 07:58:35.071405	\N	\N	f	\N	t	4	f
566	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/renta-4-bolsa-espana-diversificacion-sectorial-y-empresas-de-calidad	172	3	2025-11-04 21:33:31.158813	2025-11-05 07:53:54.55291	\N	\N	f	\N	t	4	f
567	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/y-ahora-como-gestiono-mis-ahorros	172	3	2025-11-04 21:33:32.461718	2025-11-05 07:53:55.737409	\N	\N	f	\N	t	4	f
568	https://www.r4.com/fondos-de-inversion/fondos/LU0625738058	258	3	2025-11-04 21:33:33.670031	2025-11-05 07:53:57.019049	\N	\N	f	\N	t	4	f
569	https://www.r4.com/fondos-de-inversion/fondos/LU0261952682	258	3	2025-11-04 21:33:34.894361	2025-11-05 07:53:58.26105	\N	\N	f	\N	t	4	f
570	https://www.r4.com/fondos-de-inversion/fondos/IE00BYX5NX33	258	3	2025-11-04 21:33:36.137343	2025-11-05 07:53:59.464535	\N	\N	f	\N	t	4	f
571	https://www.r4.com/fondos-de-inversion/fondos/LU0996177134	258	3	2025-11-04 21:33:37.471411	2025-11-05 07:54:00.717503	\N	\N	f	\N	t	4	f
572	https://www.r4.com/fondos-de-inversion/fondos/IE0032620787	258	3	2025-11-04 21:33:38.827049	2025-11-05 07:54:01.919888	\N	\N	f	\N	t	4	f
573	https://www.r4.com/fondos-de-inversion/fondos/LU1050469367	258	3	2025-11-04 21:33:40.212262	2025-11-05 07:54:03.188219	\N	\N	f	\N	t	4	f
574	https://www.r4.com/fondos-de-inversion/fondos/IE0009591805	258	3	2025-11-04 21:33:41.646598	2025-11-05 07:54:04.433318	\N	\N	f	\N	t	4	f
575	https://www.r4.com/fondos-de-inversion/fondos/LU1050470373	258	3	2025-11-04 21:33:44.192981	2025-11-05 07:54:05.645509	\N	\N	f	\N	t	4	f
576	https://www.r4.com/fondos-de-inversion/fondos/LU0836513266	258	3	2025-11-04 21:33:45.670357	2025-11-05 07:54:06.929254	\N	\N	f	\N	t	4	f
577	https://www.r4.com/content/rentabanco/r4/es/broker-online/productos-de-inversion/renta-fija/que-es-renta-fija	292	3	2025-11-04 21:33:47.03061	2025-11-05 07:54:08.210422	\N	\N	f	\N	t	4	f
582	https://r4.com/portal?TX=goto&FWD=MAIN10&PAG=6	301	3	2025-11-04 21:33:53.573227	2025-11-05 07:54:14.375906	\N	\N	f	\N	t	4	f
583	https://r4.com/broker-online/herramientas	301	3	2025-11-04 21:33:55.15721	2025-11-05 07:54:15.57127	\N	\N	f	\N	t	4	f
584	https://r4.com/fondos-de-inversion/servicios/ahorro-periodico	301	3	2025-11-04 21:33:56.500266	2025-11-05 07:54:16.890125	\N	\N	f	\N	t	4	f
585	https://r4.com/que-necesitas/servicios-bancarios	301	3	2025-11-04 21:33:57.801283	2025-11-05 07:54:18.185327	\N	\N	f	\N	t	4	f
586	https://r4.com/normativa	301	3	2025-11-04 21:33:59.091538	2025-11-05 07:54:19.432322	\N	\N	f	\N	t	4	f
588	https://r4.com/que-necesitas/formacion/boletines	301	3	2025-11-04 21:34:02.227688	2025-11-05 07:54:21.972321	\N	\N	f	\N	t	4	f
589	https://r4.com/tarifas	301	3	2025-11-04 21:34:03.761459	2025-11-05 07:54:23.277868	\N	\N	f	\N	t	4	f
590	https://r4.com/que-necesitas/app-renta4	301	3	2025-11-04 21:34:05.080821	2025-11-05 07:54:24.666309	\N	\N	f	\N	t	4	f
591	https://r4.com/contacto	301	3	2025-11-04 21:34:06.570484	2025-11-05 07:54:25.925216	\N	\N	f	\N	t	4	f
592	https://r4.com/que-necesitas/red-oficinas	301	3	2025-11-04 21:34:07.860206	2025-11-05 07:54:27.190332	\N	\N	f	\N	t	4	f
593	https://r4.com/articulos-y-analisis/area-prensa	301	3	2025-11-04 21:34:09.201589	2025-11-05 07:54:28.542244	\N	\N	f	\N	t	4	f
594	https://r4.com/que-necesitas/formacion/ahorrador-a-inversor	301	3	2025-11-04 21:34:10.549577	2025-11-05 07:54:29.786598	\N	\N	f	\N	t	4	f
595	https://r4.com/que-necesitas/compromiso-social	301	3	2025-11-04 21:34:11.85981	2025-11-05 07:54:31.077293	\N	\N	f	\N	t	4	f
596	https://r4.com/hazte-cliente	301	3	2025-11-04 21:34:13.14963	2025-11-05 07:54:32.350535	\N	\N	f	\N	t	4	f
598	https://r4.com/normativa/aviso-legal	301	3	2025-11-04 21:34:15.799161	2025-11-05 07:54:34.889438	\N	\N	f	\N	t	4	f
599	https://r4.com/normativa/politica-privacidad	301	3	2025-11-04 21:34:17.073074	2025-11-05 07:54:36.089487	\N	\N	f	\N	t	4	f
600	https://r4.com/normativa/politica-cookies	301	3	2025-11-04 21:34:18.424501	2025-11-05 07:54:37.352	\N	\N	f	\N	t	4	f
605	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0178430E18	306	3	2025-11-04 21:34:24.778073	2025-11-05 07:54:43.126161	\N	\N	f	\N	t	4	f
606	https://www.r4.com/autor/paula-sampedro	366	3	2025-11-04 21:34:26.195991	2025-11-05 07:54:44.269263	\N	\N	f	\N	t	4	f
607	https://www.r4.com/autor/natalia-aguirre	384	3	2025-11-04 21:34:27.359726	2025-11-05 07:54:45.393372	\N	\N	f	\N	t	4	f
608	https://www.r4.com/articulos-y-analisis/informes-de-analisis/la-fiesta-bursatil-continua	384	3	2025-11-04 21:34:28.538425	2025-11-05 07:54:46.519448	\N	\N	f	\N	t	4	f
609	https://www.r4.com/articulos-y-analisis/informes-de-analisis/bolsas-en-maximos-riesgos-en-agosto	384	3	2025-11-04 21:34:29.700642	2025-11-05 07:54:47.643554	\N	\N	f	\N	t	4	f
610	https://www.r4.com/articulos-y-analisis/informes-de-analisis/ultima-mano-en-la-partida-de-aranceles	384	3	2025-11-04 21:34:30.88804	2025-11-05 07:54:48.763335	\N	\N	f	\N	t	4	f
611	https://www.r4.com/articulos-y-analisis/informes-de-analisis/el-bono-frena-a-trump	384	3	2025-11-04 21:34:32.090408	2025-11-05 07:54:50.944736	\N	\N	f	\N	t	4	f
657	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=NL0000334118&MKT=MAS	402	3	2025-11-04 21:35:27.863459	2025-11-05 07:55:53.315439	\N	\N	f	\N	t	4	f
1133	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0118594417	703	4	2025-11-04 21:47:31.84582	2025-11-05 08:07:58.916864	\N	\N	f	\N	t	4	f
613	https://www.r4.com/articulos-y-analisis/informes-de-analisis/amazon-y-apple-impulsan-al-nasdaq-hoy-atentos-a-inflacion-ee-uu-y-eurozona-y-bateria-de-resultados-empresariales	385	3	2025-11-04 21:34:34.530211	2025-11-05 07:54:54.283772	\N	\N	f	\N	t	4	f
615	https://www.r4.com/articulos-y-analisis/informes-de-analisis/nvidia-en-maximos-historicos-hoy-fed-25pb-y-numerosos-resultados-incluidos-3-de-los-7-magnificos	385	3	2025-11-04 21:34:36.968985	2025-11-05 07:54:56.624172	\N	\N	f	\N	t	4	f
616	https://www.r4.com/articulos-y-analisis/informes-de-analisis/resultados-empresariales-bancos-centrales-y-el-encuentro-xi-jinping-trump-marcaran-la-semana	387	3	2025-11-04 21:34:38.176598	2025-11-05 07:54:57.831367	\N	\N	f	\N	t	4	f
617	https://www.r4.com/articulos-y-analisis/informes-de-analisis/foco-en-resultados-3t25-y-tensiones-comerciales-con-francia-en-el-centro-politico	387	3	2025-11-04 21:34:39.43575	2025-11-05 07:54:59.00732	\N	\N	f	\N	t	4	f
618	https://www.r4.com/articulos-y-analisis/informes-de-analisis/foco-en-la-temporada-de-resultados-3t25-con-nuevas-tensiones-ee-uu-china-como-telon-de-fondo	387	3	2025-11-04 21:34:40.663551	2025-11-05 07:55:01.492339	\N	\N	f	\N	t	4	f
619	https://www.r4.com/articulos-y-analisis/informes-de-analisis/el-shutdown-nos-deja-sin-datos-pendientes-de-la-opep	387	3	2025-11-04 21:34:41.907184	2025-11-05 07:55:03.989711	\N	\N	f	\N	t	4	f
620	https://www.r4.com/articulos-y-analisis/tecnico/fomo-en-el-4t	389	3	2025-11-04 21:34:43.262788	2025-11-05 07:55:05.145492	\N	\N	f	\N	t	4	f
621	https://www.r4.com/articulos-y-analisis/tecnico/las-recuperaciones-de-2020-y-2025-un-paralelismo-evidente	389	3	2025-11-04 21:34:44.441847	2025-11-05 07:55:07.406546	\N	\N	f	\N	t	4	f
622	https://www.r4.com/articulos-y-analisis/tecnico/los-indices-americanos-lucen-en-un-mar-de-incertidumbre	389	3	2025-11-04 21:34:45.658364	2025-11-05 07:55:08.592313	\N	\N	f	\N	t	4	f
623	https://www.r4.com/articulos-y-analisis/tecnico/los-indices-vuelan-en-v	389	3	2025-11-04 21:34:46.847359	2025-11-05 07:55:10.904578	\N	\N	f	\N	t	4	f
624	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=ES0173321003&DIVI=EUR&CBR=	390	3	2025-11-04 21:34:48.055045	2025-11-05 07:55:13.346122	\N	\N	f	\N	t	4	f
625	https://www.r4.com/digital/recanalisis/empresas.html	391	3	2025-11-04 21:34:49.210162	2025-11-05 07:55:14.522915	\N	\N	f	\N	t	4	f
626	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU0960403268&DIVI=USD&CBR=	392	3	2025-11-04 21:34:50.391329	2025-11-05 07:55:15.705584	\N	\N	f	\N	t	4	f
627	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU0569862609&DIVI=EUR&CBR=	392	3	2025-11-04 21:34:51.571217	2025-11-05 07:55:16.876853	\N	\N	f	\N	t	4	f
628	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU0289214628&DIVI=EUR&CBR=	392	3	2025-11-04 21:34:52.730714	2025-11-05 07:55:18.034432	\N	\N	f	\N	t	4	f
629	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU2145461757&DIVI=EUR&CBR=	392	3	2025-11-04 21:34:53.88891	2025-11-05 07:55:19.196223	\N	\N	f	\N	t	4	f
630	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU0302296495&DIVI=EUR&CBR=	392	3	2025-11-04 21:34:55.043434	2025-11-05 07:55:20.340306	\N	\N	f	\N	t	4	f
631	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=ES0173130024&DIVI=EUR&CBR=	392	3	2025-11-04 21:34:56.243771	2025-11-05 07:55:21.504136	\N	\N	f	\N	t	4	f
632	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=IE00BZ18VZ93&DIVI=EUR&CBR=	392	3	2025-11-04 21:34:57.395034	2025-11-05 07:55:22.694897	\N	\N	f	\N	t	4	f
633	https://www.r4.com/portal?TX=goto&FWD=MAIN_FND_R4&PAG=5&SUB_HOJ=2&CHOJ=2	392	3	2025-11-04 21:34:58.540453	2025-11-05 07:55:23.842219	\N	\N	f	\N	t	4	f
634	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=FR0000131104&MKT=MPA	393	3	2025-11-04 21:34:59.694677	2025-11-05 07:55:24.990811	\N	\N	f	\N	t	4	f
635	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=ES0173322001&DIVI=EUR&CBR=	394	3	2025-11-04 21:35:00.878184	2025-11-05 07:55:26.159932	\N	\N	f	\N	t	4	f
636	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/comprar-las-companias-mas-baratas-no-funciona	395	3	2025-11-04 21:35:02.04039	2025-11-05 07:55:27.351833	\N	\N	f	\N	t	4	f
637	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/roce-el-mejor-indicador-para-predecir-la-futura-rentabilidad-pero-la-menos-utilizada-por-los-inversores	395	3	2025-11-04 21:35:03.240609	2025-11-05 07:55:28.568845	\N	\N	f	\N	t	4	f
638	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=ES0173130065&DIVI=EUR&CBR=	396	3	2025-11-04 21:35:04.427116	2025-11-05 07:55:29.785747	\N	\N	f	\N	t	4	f
639	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/oportunidad-historica-para-invertir-en-small-caps	397	3	2025-11-04 21:35:05.599435	2025-11-05 07:55:31.007429	\N	\N	f	\N	t	4	f
640	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/perspectivas-de-la-renta-variable-para-2024-resolviendo-algunas-cuestiones	397	3	2025-11-04 21:35:06.791576	2025-11-05 07:55:32.212191	\N	\N	f	\N	t	4	f
641	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/invertir-en-ladrillo-a-traves-de-socimis	397	3	2025-11-04 21:35:07.982678	2025-11-05 07:55:33.390483	\N	\N	f	\N	t	4	f
642	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/la-renta-variable-en-el-entorno-actual	397	3	2025-11-04 21:35:09.253649	2025-11-05 07:55:34.596459	\N	\N	f	\N	t	4	f
643	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US0231351067&MKT=MMO	400	3	2025-11-04 21:35:10.53081	2025-11-05 07:55:35.794991	\N	\N	f	\N	t	4	f
644	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US30303M1027&MKT=MMO	400	3	2025-11-04 21:35:11.697449	2025-11-05 07:55:36.985965	\N	\N	f	\N	t	4	f
646	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US02079K3059&MKT=MMO	400	3	2025-11-04 21:35:14.031725	2025-11-05 07:55:39.362797	\N	\N	f	\N	t	4	f
647	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US68389X1054&MKT=MMN	400	3	2025-11-04 21:35:15.202073	2025-11-05 07:55:40.536304	\N	\N	f	\N	t	4	f
648	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US67066G1040&MKT=MMO	400	3	2025-11-04 21:35:16.362083	2025-11-05 07:55:41.728487	\N	\N	f	\N	t	4	f
649	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US11135F1012&MKT=MMO	400	3	2025-11-04 21:35:17.523216	2025-11-05 07:55:42.905317	\N	\N	f	\N	t	4	f
650	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US5128073062&MKT=MMO	400	3	2025-11-04 21:35:18.68074	2025-11-05 07:55:44.101478	\N	\N	f	\N	t	4	f
651	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US4824801009&MKT=MMO	400	3	2025-11-04 21:35:19.918301	2025-11-05 07:55:45.302161	\N	\N	f	\N	t	4	f
652	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US0382221051&MKT=MMO	400	3	2025-11-04 21:35:21.091707	2025-11-05 07:55:46.453856	\N	\N	f	\N	t	4	f
653	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US8740391003&MKT=MMN	400	3	2025-11-04 21:35:22.252602	2025-11-05 07:55:47.632677	\N	\N	f	\N	t	4	f
654	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=ES0173057011&DIVI=EUR&CBR=	400	3	2025-11-04 21:35:23.404202	2025-11-05 07:55:48.81791	\N	\N	f	\N	t	4	f
655	https://www.r4.com/academiar4/formulario-cursos?id=4367	401	3	2025-11-04 21:35:24.562911	2025-11-05 07:55:49.977689	\N	\N	f	\N	t	4	f
656	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=NL0010273215&MKT=MAS	402	3	2025-11-04 21:35:26.720056	2025-11-05 07:55:52.15359	\N	\N	f	\N	t	4	f
660	https://www.r4.com/articulos-y-analisis/ideas/coursera-aprendizaje-oportunidad-inversion	403	3	2025-11-04 21:35:31.563246	2025-11-05 07:55:56.906424	\N	\N	f	\N	t	4	f
661	https://www.r4.com/autor/celso-otero	403	3	2025-11-04 21:35:32.847868	2025-11-05 07:55:58.118472	\N	\N	f	\N	t	4	f
662	https://www.r4.com/articulos-y-analisis/ideas/santander-en-cartera-dividendo	403	3	2025-11-04 21:35:34.03149	2025-11-05 07:55:59.354241	\N	\N	f	\N	t	4	f
663	https://www.r4.com/articulos-y-analisis/ideas/mercados-burbuja-25-anos	403	3	2025-11-04 21:35:35.201524	2025-11-05 07:56:00.573427	\N	\N	f	\N	t	4	f
664	https://www.r4.com/articulos-y-analisis/ideas/bonos-largo-plazo-vuelta-al-atractivo	403	3	2025-11-04 21:35:36.382433	2025-11-05 07:56:01.807766	\N	\N	f	\N	t	4	f
665	https://www.r4.com/articulos-y-analisis/ideas/cirsa-en-cartera-versatil-5-grandes	403	3	2025-11-04 21:35:38.512461	2025-11-05 07:56:03.04737	\N	\N	f	\N	t	4	f
666	https://www.r4.com/articulos-y-analisis/ideas/revision-carteras-fondos-9M25	403	3	2025-11-04 21:35:39.801488	2025-11-05 07:56:04.210387	\N	\N	f	\N	t	4	f
667	https://www.r4.com/autor/jose-hinojo	403	3	2025-11-04 21:35:41.037757	2025-11-05 07:56:05.420066	\N	\N	f	\N	t	4	f
668	https://www.r4.com/articulos-y-analisis/ideas/carteras-sale-sabadell-entra-caixa	403	3	2025-11-04 21:35:42.284469	2025-11-05 07:56:06.635142	\N	\N	f	\N	t	4	f
669	https://www.r4.com/articulos-y-analisis/ideas/3	403	3	2025-11-04 21:35:43.479171	2025-11-05 07:56:07.880138	\N	\N	f	\N	t	4	f
672	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-nvidia-y-las-burbujas-buenas	406	3	2025-11-04 21:35:47.251664	2025-11-05 07:56:11.946045	\N	\N	f	\N	t	4	f
673	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-la-rotacion-llega-al-sector-salud	406	3	2025-11-04 21:35:49.501384	2025-11-05 07:56:13.162978	\N	\N	f	\N	t	4	f
674	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/caida-del-dolar-sus-causas-y-consecuencias	407	3	2025-11-04 21:35:51.69846	2025-11-05 07:56:14.383664	\N	\N	f	\N	t	4	f
675	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/usar-la-ia-estadounidense-definira-quienes-son-los-aliados-de-estados-unidos	407	3	2025-11-04 21:35:52.899066	2025-11-05 07:56:15.614839	\N	\N	f	\N	t	4	f
676	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/powell-vive-su-momento-greenspan	416	3	2025-11-04 21:35:55.176432	2025-11-05 07:56:16.884865	\N	\N	f	\N	t	4	f
677	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-el-ether-corrige-su-frenesi-especulativo-mientras-el-dolar-sorprende-al-alza	416	3	2025-11-04 21:35:57.33314	2025-11-05 07:56:18.080666	\N	\N	f	\N	t	4	f
678	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/ia-la-necesidad-de-energia-abundante-y-barata-y-la-irrelevancia-de-europa	416	3	2025-11-04 21:35:58.518249	2025-11-05 07:56:19.286887	\N	\N	f	\N	t	4	f
679	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/que-ha-cambiado-desde-abril	416	3	2025-11-04 21:35:59.754262	2025-11-05 07:56:20.492734	\N	\N	f	\N	t	4	f
680	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-la-fed-baja-tipos-y-el-dolar-sube-una-nueva-paradoja	416	3	2025-11-04 21:36:01.893646	2025-11-05 07:56:22.725548	\N	\N	f	\N	t	4	f
681	https://www.r4.com/articulos-y-analisis/mercados/3	416	3	2025-11-04 21:36:03.059515	2025-11-05 07:56:23.921653	\N	\N	f	\N	t	4	f
682	https://www.r4.com/serviciosr4/boletin-analisis-fundamental-diario	417	3	2025-11-04 21:36:04.28264	2025-11-05 07:56:25.140291	\N	\N	f	\N	t	4	f
683	https://www.r4.com/content/rentabanco/r4/es/articulos-y-analisis/seguimiento-de-companias	417	3	2025-11-04 21:36:05.417334	2025-11-05 07:56:26.284359	\N	\N	f	\N	t	4	f
684	https://www.r4.com/articulos-y-analisis/valores/puig-brands-avance-ventas-3t25-recuperando-guia-y-anunciado-cmd-en-abril	418	3	2025-11-04 21:36:06.637242	2025-11-05 07:56:27.594666	\N	\N	f	\N	t	4	f
686	https://www.r4.com/articulos-y-analisis/valores/repsol-3t25-no-news-good-news	418	3	2025-11-04 21:36:09.062116	2025-11-05 07:56:31.027282	\N	\N	f	\N	t	4	f
687	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0132105018	420	3	2025-11-04 21:36:11.374681	2025-11-05 07:56:33.218145	\N	\N	f	\N	t	4	f
688	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-previo-3t25-confirmando-la-aceleracion-hacia-un-ano-record	421	3	2025-11-04 21:36:12.608801	2025-11-05 07:56:35.279518	\N	\N	f	\N	t	4	f
689	https://www.r4.com/articulos-y-analisis/valores/ebro-foods-9m25-en-linea-cifras-pre-cierre-2025-ligeramente-por-debajo-el-consenso	421	3	2025-11-04 21:36:13.822875	2025-11-05 07:56:36.504152	\N	\N	f	\N	t	4	f
690	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0132945017	422	3	2025-11-04 21:36:15.025518	2025-11-05 07:56:37.65225	\N	\N	f	\N	t	4	f
691	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0176252718	423	3	2025-11-04 21:36:16.248977	2025-11-05 07:56:38.828658	\N	\N	f	\N	t	4	f
692	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0180907000	424	3	2025-11-04 21:36:17.436389	2025-11-05 07:56:39.9669	\N	\N	f	\N	t	4	f
693	https://www.r4.com/articulos-y-analisis/valores/caixabank-resultados-3t25-mejoran-ligeramente-guias-en-un-entorno-de-aceleracion-de-volumenes	425	3	2025-11-04 21:36:18.719984	2025-11-05 07:56:41.151195	\N	\N	f	\N	t	4	f
694	https://www.r4.com/articulos-y-analisis/valores/bbva-3t25-resultados-mixtos-fortaleza-del-margen-de-intereses-vs-aumento-del-coste-de-riesgo-mantener-p-o-16-91-eur-acc	425	3	2025-11-04 21:36:21.09624	2025-11-05 07:56:42.29115	\N	\N	f	\N	t	4	f
695	https://www.r4.com/articulos-y-analisis/valores/santander-resultados-9m25-santander-3t25-cifras-en-linea-con-estimaciones-atencion-al-margen-bruto	425	3	2025-11-04 21:36:22.356598	2025-11-05 07:56:43.495656	\N	\N	f	\N	t	4	f
696	https://www.r4.com/articulos-y-analisis/valores/ebro-ev-motors-1s25-en-proceso-de-ramp-up-reafirma-objetivos-para-el-conjunto-del-ano	427	3	2025-11-04 21:36:24.711263	2025-11-05 07:56:45.743759	\N	\N	f	\N	t	4	f
697	https://www.r4.com/articulos-y-analisis/valores/izertis-adquisicion-del-negocio-de-transformacion-digital-del-grupo-ica	427	3	2025-11-04 21:36:26.878333	2025-11-05 07:56:48.061843	\N	\N	f	\N	t	4	f
698	https://www.r4.com/articulos-y-analisis/valores/solaria-1s25-resultados-solidos-apoyados-en-generia	427	3	2025-11-04 21:36:29.027075	2025-11-05 07:56:49.262021	\N	\N	f	\N	t	4	f
699	https://www.r4.com/articulos-y-analisis/valores/inmobiliaria-del-sur-3t25-9m25-resultados-en-linea-confirmando-buen-tono-operativo	428	3	2025-11-04 21:36:31.379107	2025-11-05 07:56:50.466639	\N	\N	f	\N	t	4	f
700	https://www.r4.com/articulos-y-analisis/valores/vidrala-mejorando-la-rentabilidad-en-espera-de-la-recuperacion-de-la-demanda	428	3	2025-11-04 21:36:33.940203	2025-11-05 07:56:51.638691	\N	\N	f	\N	t	4	f
701	https://www.r4.com/articulos-y-analisis/valores/previo-sacyr-9m25-buena-evolucion-trimestral-alineada-con-la-tendencia-anterior	428	3	2025-11-04 21:36:36.298132	2025-11-05 07:56:54.032413	\N	\N	f	\N	t	4	f
702	https://www.r4.com/articulos-y-analisis/valores/ence-3t25-plan-de-eficiencia-necesario-pero-no-suficiente-para-cumplir-objetivos	428	3	2025-11-04 21:36:37.499866	2025-11-05 07:56:55.235827	\N	\N	f	\N	t	4	f
703	https://www.r4.com/articulos-y-analisis/valores/indra-resultados-3t-25-que-incumplen-previsiones-a-nivel-operativo-mantienen-la-guia-2025e	428	3	2025-11-04 21:36:39.718487	2025-11-05 07:56:56.424914	\N	\N	f	\N	t	4	f
987	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-1t25-superan-la-prevision-de-ebitda-de-consenso-bien-posicionada-en-el-actual-escenario-de-incertidumbre	554	4	2025-11-04 21:44:13.207048	2025-11-05 08:04:36.444173	\N	\N	f	\N	t	4	f
705	https://www.r4.com/articulos-y-analisis/tecnico/estrategia-rupturas-trimestrales-actualizacion-julio-2025-entra-bouygues	430	3	2025-11-04 21:36:42.979834	2025-11-05 07:56:58.778378	\N	\N	f	\N	t	4	f
706	https://www.r4.com/articulos-y-analisis/tecnico/estrategia-rupturas-trimestrales-actualizacion-abril-2025-entra-caf	430	3	2025-11-04 21:36:45.238305	2025-11-05 07:57:01.001317	\N	\N	f	\N	t	4	f
708	https://www.r4.com/articulos-y-analisis/tecnico/estrategia-rupturas-trimestrales-actualizacion-entra-micron-technology	430	3	2025-11-04 21:36:48.676875	2025-11-05 07:57:04.783552	\N	\N	f	\N	t	4	f
709	https://www.r4.com/articulos-y-analisis/valores/idea-corto-plazo-17-alcista-sanofi	431	3	2025-11-04 21:36:51.025368	2025-11-05 07:57:05.929279	\N	\N	f	\N	t	4	f
710	https://www.r4.com/articulos-y-analisis/valores/oportunidad-de-inversion-en-el-sector-salud-usa-3-ideas	431	3	2025-11-04 21:36:53.324357	2025-11-05 07:57:08.273537	\N	\N	f	\N	t	4	f
711	https://www.r4.com/articulos-y-analisis/valores/ahora-si-que-pinta-bien-gestamp	431	3	2025-11-04 21:36:55.484741	2025-11-05 07:57:10.622325	\N	\N	f	\N	t	4	f
712	https://www.r4.com/articulos-y-analisis/valores/hemos-de-vender-santander-o-es-probable-que-siga-subiendo	431	3	2025-11-04 21:36:58.003057	2025-11-05 07:57:13.102432	\N	\N	f	\N	t	4	f
713	https://www.r4.com/articulos-y-analisis/tecnico/el-ibex-medium-cap-apunta-otro-32-al-alza-en-el-medio-plazo	441	3	2025-11-04 21:37:00.156637	2025-11-05 07:57:14.24213	\N	\N	f	\N	t	4	f
714	https://www.r4.com/articulos-y-analisis/tecnico/tubacex-se-aproxima-a-las-primeras-referencias-alcistas-de-medio-plazo	441	3	2025-11-04 21:37:02.47389	2025-11-05 07:57:15.403882	\N	\N	f	\N	t	4	f
273	https://www.r4.com/planes-de-pensiones/planes/F1605	31	2	2025-11-04 21:26:38.8857	2025-11-05 07:47:18.671366	\N	\N	f	\N	t	4	f
715	https://www.r4.com/articulos-y-analisis/tecnico/por-que-sufrir-con-el-sector-auto-si-tenemos-a-cie-automotive	441	3	2025-11-04 21:37:03.665078	2025-11-05 07:57:16.581841	\N	\N	f	\N	t	4	f
716	https://www.r4.com/articulos-y-analisis/tecnico/almirall-consistente-y-discretamente-alcista	441	3	2025-11-04 21:37:04.860883	2025-11-05 07:57:17.766973	\N	\N	f	\N	t	4	f
717	https://www.r4.com/articulos-y-analisis/tecnico/la-sensibilidad-de-los-indices-del-miedo-son-buenas-noticias-para-los-alcistas	441	3	2025-11-04 21:37:06.033721	2025-11-05 07:57:18.904496	\N	\N	f	\N	t	4	f
718	https://www.r4.com/articulos-y-analisis/tecnico/la-senal-tecnica-que-sugiere-un-largo-plazo-alcista-en-enagas	441	3	2025-11-04 21:37:07.241309	2025-11-05 07:57:21.271395	\N	\N	f	\N	t	4	f
719	https://www.r4.com/articulos-y-analisis/tecnico/cellnex-adentrandose-de-nuevo-en-zonas-de-soporte-de-5-anos	441	3	2025-11-04 21:37:08.424026	2025-11-05 07:57:22.549487	\N	\N	f	\N	t	4	f
720	https://www.r4.com/articulos-y-analisis/tecnico/ferrari-deberia-frenar-ante-niveles-clave	441	3	2025-11-04 21:37:09.595553	2025-11-05 07:57:24.752011	\N	\N	f	\N	t	4	f
721	https://www.r4.com/articulos-y-analisis/tecnico/la-caida-del-25-en-deutsche-boerse-que-comienza-a-ser-atractiva-para-comprar	441	3	2025-11-04 21:37:10.787113	2025-11-05 07:57:27.178777	\N	\N	f	\N	t	4	f
722	https://www.r4.com/articulos-y-analisis/tecnico/3	441	3	2025-11-04 21:37:11.980204	2025-11-05 07:57:29.53353	\N	\N	f	\N	t	4	f
723	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU0787776565&DIVI=EUR&CBR=	442	3	2025-11-04 21:37:13.183645	2025-11-05 07:57:30.686862	\N	\N	f	\N	t	4	f
724	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU0348784041&DIVI=EUR&CBR=	442	3	2025-11-04 21:37:14.356117	2025-11-05 07:57:31.860621	\N	\N	f	\N	t	4	f
726	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/como-es-la-gestion-de-un-fondo-ganador-actualidad-a-fondo	451	3	2025-11-04 21:37:16.701825	2025-11-05 07:57:34.258302	\N	\N	f	\N	t	4	f
727	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/defiendete-de-la-inflacion-sigue-invirtiendo-y-recuerda-slow-finance	451	3	2025-11-04 21:37:17.877292	2025-11-05 07:57:35.431765	\N	\N	f	\N	t	4	f
728	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/por-que-pierdo-en-mi-fondo-con-renta-fija-y-es-una-gran-oportunidad	451	3	2025-11-04 21:37:19.162065	2025-11-05 07:57:37.70693	\N	\N	f	\N	t	4	f
729	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/renta-4-megatendencias-salud-diversificar-en-activos-del-sector-salud	455	3	2025-11-04 21:37:20.352366	2025-11-05 07:57:38.935552	\N	\N	f	\N	t	4	f
730	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/la-inversion-en-salud-en-el-tercer-aniversario-de-renta-4-megatendencias-salud-actualidad-a-fondo	455	3	2025-11-04 21:37:21.528869	2025-11-05 07:57:41.13836	\N	\N	f	\N	t	4	f
731	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/invertir-en-salud-en-la-era-poscovid	455	3	2025-11-04 21:37:22.719088	2025-11-05 07:57:42.313009	\N	\N	f	\N	t	4	f
732	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/un-gran-ano-para-la-inversion-en-salud-reflexiones-sobre-inversion-en-2021	455	3	2025-11-04 21:37:23.934596	2025-11-05 07:57:43.499648	\N	\N	f	\N	t	4	f
733	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/renta-4-nexus-inversion-flexible-para-adaptarse-al-mercado	457	3	2025-11-04 21:37:25.133558	2025-11-05 07:57:44.650146	\N	\N	f	\N	t	4	f
734	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/un-fondo-con-flexibilidad-para-obtener-resultados-actualidad-a-fondo	457	3	2025-11-04 21:37:26.334757	2025-11-05 07:57:45.817616	\N	\N	f	\N	t	4	f
735	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/reflexiones-de-un-gestor-frustrado	457	3	2025-11-04 21:37:27.528404	2025-11-05 07:57:46.988138	\N	\N	f	\N	t	4	f
736	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/como-gestionar-en-momentos-de-incertidumbre	457	3	2025-11-04 21:37:28.717761	2025-11-05 07:57:49.22558	\N	\N	f	\N	t	4	f
737	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-bolsa-espana-a-cierre-de-septiembre-de-2025	458	3	2025-11-04 21:37:29.906919	2025-11-05 07:57:50.389482	\N	\N	f	\N	t	4	f
738	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-megatendencias-medio-ambiente-a-cierre-de-septiembre-de-2025	458	3	2025-11-04 21:37:31.117884	2025-11-05 07:57:51.548161	\N	\N	f	\N	t	4	f
739	https://www.r4.com/autor/jaime-vazquez	458	3	2025-11-04 21:37:32.299064	2025-11-05 07:57:52.691464	\N	\N	f	\N	t	4	f
740	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-nexus-a-cierre-de-septiembre-de-2025	458	3	2025-11-04 21:37:34.420919	2025-11-05 07:57:55.028232	\N	\N	f	\N	t	4	f
742	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-megatendencias-consumo-a-cierre-de-septiembre-de-2025	458	3	2025-11-04 21:37:37.89225	2025-11-05 07:57:58.475379	\N	\N	f	\N	t	4	f
743	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-megatendencias-tecnologia-a-cierre-de-septiembre-de-2025	458	3	2025-11-04 21:37:39.097974	2025-11-05 07:58:00.797361	\N	\N	f	\N	t	4	f
744	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-small-caps-global-a-cierre-de-septiembre-de-2025	458	3	2025-11-04 21:37:41.390313	2025-11-05 07:58:02.992457	\N	\N	f	\N	t	4	f
745	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-europa-acciones-a-cierre-de-septiembre-de-2025	458	3	2025-11-04 21:37:43.514231	2025-11-05 07:58:05.412398	\N	\N	f	\N	t	4	f
746	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-activos-globales-a-cierre-de-septiembre-de-2025	458	3	2025-11-04 21:37:44.78941	2025-11-05 07:58:06.581682	\N	\N	f	\N	t	4	f
1030	https://r4.com/que-necesitas/servicios-bancarios/bizum	585	4	2025-11-04 21:45:03.770348	2025-11-05 08:05:33.28898	\N	\N	f	\N	t	4	f
1585	https://www.r4.com/articulos-y-analisis/valores/caixabank-2t25-mejoran-ligeramente-guias-menores-provisiones-apoyan-al-beneficio-neto	1127	5	2025-11-04 21:59:54.894446	2025-11-05 08:21:20.077568	\N	\N	f	\N	t	4	f
748	https://www.r4.com/articulos-y-analisis/fondos/3	458	3	2025-11-04 21:37:47.234329	2025-11-05 07:58:10.977294	\N	\N	f	\N	t	4	f
749	https://www.r4.com/articulos-y-analisis/cripto/unica-constante-debilitar-dolar	468	3	2025-11-04 21:37:48.459858	2025-11-05 07:58:12.181954	\N	\N	f	\N	t	4	f
751	https://www.r4.com/articulos-y-analisis/cripto/stablecoins-la-nueva-frontera-corporativa	468	3	2025-11-04 21:37:50.836631	2025-11-05 07:58:16.533009	\N	\N	f	\N	t	4	f
752	https://www.r4.com/articulos-y-analisis/cripto/bitcoin-entre-tensiones-globales-y-apetito-institucional	468	3	2025-11-04 21:37:52.022684	2025-11-05 07:58:19.03399	\N	\N	f	\N	t	4	f
753	https://www.r4.com/articulos-y-analisis/cripto/cuando-el-sistema-falla-y-bitcoin-duda	468	3	2025-11-04 21:37:53.247555	2025-11-05 07:58:21.382199	\N	\N	f	\N	t	4	f
754	https://www.r4.com/articulos-y-analisis/cripto/la-guerra-por-el-futuro-financiero	468	3	2025-11-04 21:37:54.409763	2025-11-05 07:58:23.700473	\N	\N	f	\N	t	4	f
755	https://www.r4.com/articulos-y-analisis/cripto/bitcoin-celebra-el-pizza-day	468	3	2025-11-04 21:37:55.583164	2025-11-05 07:58:25.979697	\N	\N	f	\N	t	4	f
756	https://www.r4.com/articulos-y-analisis/cripto/la-politica-esta-en-el-precio	468	3	2025-11-04 21:37:56.742838	2025-11-05 07:58:28.41524	\N	\N	f	\N	t	4	f
757	https://www.r4.com/articulos-y-analisis/cripto/ethereum-toma-la-delantera-pectra-y-la-nueva-vision-de-vitalik	468	3	2025-11-04 21:37:57.963375	2025-11-05 07:58:30.596093	\N	\N	f	\N	t	4	f
758	https://www.r4.com/articulos-y-analisis/cripto/resiliencia-de-los-mercados-y-madurez-cripto-tras-el-liberation-day	468	3	2025-11-04 21:38:00.091042	2025-11-05 07:58:31.748784	\N	\N	f	\N	t	4	f
759	https://www.r4.com/articulos-y-analisis/cripto/3	468	3	2025-11-04 21:38:01.248179	2025-11-05 07:58:33.107859	\N	\N	f	\N	t	4	f
761	https://www.r4.com/academiar4/formulario-cursos?id=4371	489	3	2025-11-04 21:38:04.684526	2025-11-05 07:58:36.220976	\N	\N	f	\N	t	4	f
762	https://www.r4.com/academiar4/formulario-cursos?id=4372	489	3	2025-11-04 21:38:06.881113	2025-11-05 07:58:38.622952	\N	\N	f	\N	t	4	f
763	https://www.r4.com/academiar4/formulario-cursos?id=4341	489	3	2025-11-04 21:38:08.013889	2025-11-05 07:58:40.852304	\N	\N	f	\N	t	4	f
764	https://www.r4.com/academiar4/formulario-cursos?id=4376	489	3	2025-11-04 21:38:10.174652	2025-11-05 07:58:42.039023	\N	\N	f	\N	t	4	f
765	https://www.r4.com/academiar4/formulario-cursos?id=4381	489	3	2025-11-04 21:38:12.349586	2025-11-05 07:58:44.242256	\N	\N	f	\N	t	4	f
766	https://www.r4.com/academiar4/formulario-cursos?id=4375	489	3	2025-11-04 21:38:13.514829	2025-11-05 07:58:45.419227	\N	\N	f	\N	t	4	f
767	https://www.r4.com/academiar4/formulario-cursos?id=4382	489	3	2025-11-04 21:38:15.696917	2025-11-05 07:58:47.694976	\N	\N	f	\N	t	4	f
768	https://www.r4.com/academiar4/formulario-cursos?id=4342	489	3	2025-11-04 21:38:18.054533	2025-11-05 07:58:49.841077	\N	\N	f	\N	t	4	f
770	https://www.r4.com/academiar4/formulario-cursos?id=4383	489	3	2025-11-04 21:38:21.431623	2025-11-05 07:58:54.074928	\N	\N	f	\N	t	4	f
771	https://www.r4.com/academiar4/formulario-cursos?id=4377	489	3	2025-11-04 21:38:23.670189	2025-11-05 07:58:55.218241	\N	\N	f	\N	t	4	f
772	https://www.r4.com/academiar4/formulario-cursos?id=4343	489	3	2025-11-04 21:38:24.868722	2025-11-05 07:58:57.292139	\N	\N	f	\N	t	4	f
773	https://www.r4.com/academiar4/formulario-cursos?id=4344	489	3	2025-11-04 21:38:26.034478	2025-11-05 07:58:59.574989	\N	\N	f	\N	t	4	f
774	https://www.r4.com/serviciosr4/mitos-planes-de-pensiones	489	3	2025-11-04 21:38:28.292326	2025-11-05 07:59:01.843006	\N	\N	f	\N	t	4	f
775	https://www.r4.com/serviciosr4/que-es-plan-de-pensiones-guia-gratis	490	3	2025-11-04 21:38:29.416936	2025-11-05 07:59:02.966939	\N	\N	f	\N	t	4	f
776	https://www.r4.com/serviciosr4/guia-de-ahorrador-a-inversor-descarga-gratis	490	3	2025-11-04 21:38:30.813192	2025-11-05 07:59:04.084306	\N	\N	f	\N	t	4	f
777	https://www.r4.com/serviciosr4/guia-renta-fija	492	3	2025-11-04 21:38:32.344673	2025-11-05 07:59:05.250137	\N	\N	f	\N	t	4	f
781	https://www.r4.com/que-necesitas/formacion/diccionario/que-es-la-inflacion	493	3	2025-11-04 21:38:38.302242	2025-11-05 07:59:09.928083	\N	\N	f	\N	t	4	f
782	https://www.r4.com/content/rentabanco/r4/es.html	499	3	2025-11-04 21:38:40.222637	2025-11-05 07:59:11.108877	\N	\N	f	\N	t	4	f
783	https://www.r4.com/inversion-para-todos/ley-mica-de-criptomonedas-que-es-y-que-regula	507	3	2025-11-04 21:38:41.565084	2025-11-05 07:59:12.351837	\N	\N	f	\N	t	4	f
784	https://www.r4.com/inversion-para-todos/etps-que-son-y-como-puedes-invertir-en-ellos	507	3	2025-11-04 21:38:43.567462	2025-11-05 07:59:14.94513	\N	\N	f	\N	t	4	f
785	https://www.r4.com/inversion-para-todos/pasivos-financieros-que-son-tipos-y-ejemplos	507	3	2025-11-04 21:38:45.652173	2025-11-05 07:59:16.987945	\N	\N	f	\N	t	4	f
786	https://www.r4.com/inversion-para-todos/que-son-los-planes-de-pensiones-sostenibles	507	3	2025-11-04 21:38:47.113004	2025-11-05 07:59:18.422173	\N	\N	f	\N	t	4	f
787	https://www.r4.com/inversion-para-todos/que-es-la-banca-de-inversion-y-como-funciona	507	3	2025-11-04 21:38:48.612562	2025-11-05 07:59:20.023113	\N	\N	f	\N	t	4	f
788	https://www.r4.com/inversion-para-todos/conoce-las-ventajas-de-ahorrar-en-un-banco	507	3	2025-11-04 21:38:50.092773	2025-11-05 07:59:21.590266	\N	\N	f	\N	t	4	f
790	https://www.r4.com/inversion-para-todos/coste-de-oportunidad-que-es-y-como-se-calcula	507	3	2025-11-04 21:38:53.535808	2025-11-05 07:59:24.570154	\N	\N	f	\N	t	4	f
791	https://www.r4.com/inversion-para-todos/como-reducir-tus-deudas-5-estrategias-y-consejos	507	3	2025-11-04 21:38:55.192469	2025-11-05 07:59:26.142028	\N	\N	f	\N	t	4	f
792	https://www.r4.com/inversion-para-todos/que-es-el-stress-test-prueba-de-resistencia-bancaria	507	3	2025-11-04 21:38:56.814023	2025-11-05 07:59:27.703245	\N	\N	f	\N	t	4	f
793	https://www.r4.com/inversion-para-todos/que-es-el-sistema-triple-pantalla-de-alexander-elder-en-bolsa	507	3	2025-11-04 21:38:58.288039	2025-11-05 07:59:29.243136	\N	\N	f	\N	t	4	f
794	https://www.r4.com/inversion-para-todos/retroceso-de-fibonacci-que-es-y-como-utilizarlo-en-trading	507	3	2025-11-04 21:38:59.787328	2025-11-05 07:59:30.768583	\N	\N	f	\N	t	4	f
795	https://www.r4.com/inversion-para-todos/que-es-el-mercado-monetario-y-cual-es-su-funcion	507	3	2025-11-04 21:39:01.632764	2025-11-05 07:59:32.257996	\N	\N	f	\N	t	4	f
796	https://www.r4.com/inversion-para-todos/que-son-los-seguros-de-vida-como-funcionan-y-para-que-sirven	507	3	2025-11-04 21:39:03.171839	2025-11-05 07:59:33.83074	\N	\N	f	\N	t	4	f
797	https://www.r4.com/inversion-para-todos/que-es-y-como-calcular-la-base-reguladora	507	3	2025-11-04 21:39:05.570915	2025-11-05 07:59:35.420185	\N	\N	f	\N	t	4	f
798	https://www.r4.com/inversion-para-todos/sell-in-may-and-go-away-que-significa	507	3	2025-11-04 21:39:07.287568	2025-11-05 07:59:37.108417	\N	\N	f	\N	t	4	f
799	https://www.r4.com/inversion-para-todos/que-son-los-productos-cotizados-y-como-invertir-en-ellos	507	3	2025-11-04 21:39:08.796837	2025-11-05 07:59:38.757149	\N	\N	f	\N	t	4	f
1077	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-oracle-y-la-paradoja-del-bitcoin	680	4	2025-11-04 21:46:19.187277	2025-11-05 08:06:46.312642	\N	\N	f	\N	t	4	f
801	https://www.r4.com/inversion-para-todos/que-es-inversion-alternativa	507	3	2025-11-04 21:39:11.769943	2025-11-05 07:59:42.126267	\N	\N	f	\N	t	4	f
802	https://www.r4.com/inversion-para-todos/category/curiosidades-financieras/page/2	507	3	2025-11-04 21:39:13.257829	2025-11-05 07:59:43.818539	\N	\N	f	\N	t	4	f
803	https://www.r4.com/inversion-para-todos/category/curiosidades-financieras/page/6	507	3	2025-11-04 21:39:14.844432	2025-11-05 07:59:45.882109	\N	\N	f	\N	t	4	f
804	https://www.r4.com/inversion-para-todos/tipos-productos-inversion	508	3	2025-11-04 21:39:16.624631	2025-11-05 07:59:47.780167	\N	\N	f	\N	t	4	f
806	https://www.r4.com/inversion-para-todos/invertir-en-metales-preciosos-que-es-y-como-hacerlo	508	3	2025-11-04 21:39:19.561712	2025-11-05 07:59:52.235531	\N	\N	f	\N	t	4	f
807	https://www.r4.com/inversion-para-todos/large-caps-que-son-y-por-que-invertir-en-ellas	508	3	2025-11-04 21:39:21.27318	2025-11-05 07:59:53.861791	\N	\N	f	\N	t	4	f
808	https://www.r4.com/inversion-para-todos/invertir-en-energias-renovables-en-que-consiste-y-cuales-son-sus-ventajas	508	3	2025-11-04 21:39:22.864645	2025-11-05 07:59:55.41273	\N	\N	f	\N	t	4	f
809	https://www.r4.com/inversion-para-todos/que-son-y-como-invertir-en-indices-bursatiles	508	3	2025-11-04 21:39:24.462082	2025-11-05 07:59:57.01868	\N	\N	f	\N	t	4	f
810	https://www.r4.com/inversion-para-todos/declaracion-de-la-renta-las-desgravaciones-mas-interesantes-para-un-inversor	508	3	2025-11-04 21:39:26.129381	2025-11-05 07:59:58.637377	\N	\N	f	\N	t	4	f
811	https://www.r4.com/inversion-para-todos/guia-sobre-como-invertir-en-divisas	508	3	2025-11-04 21:39:27.642103	2025-11-05 08:00:00.586399	\N	\N	f	\N	t	4	f
812	https://www.r4.com/inversion-para-todos/ventajas-gestion-activa	508	3	2025-11-04 21:39:29.174677	2025-11-05 08:00:02.320526	\N	\N	f	\N	t	4	f
813	https://www.r4.com/inversion-para-todos/que-son-los-planes-de-ahorro-a-largo-plazo	508	3	2025-11-04 21:39:30.623142	2025-11-05 08:00:04.319431	\N	\N	f	\N	t	4	f
814	https://www.r4.com/inversion-para-todos/como-invertir-en-la-tercera-edad	508	3	2025-11-04 21:39:32.127302	2025-11-05 08:00:05.896771	\N	\N	f	\N	t	4	f
870	https://www.r4.com/inversion-para-todos/inflacion-y-ahorros	519	3	2025-11-04 21:41:00.103007	2025-11-05 08:01:43.943872	\N	\N	f	\N	t	4	f
815	https://www.r4.com/inversion-para-todos/invertir-en-biotecnologia-una-opcion-de-presente-y-futuro	508	3	2025-11-04 21:39:33.646335	2025-11-05 08:00:07.45422	\N	\N	f	\N	t	4	f
816	https://www.r4.com/inversion-para-todos/descubre-los-fondos-de-inversion-sostenibles	508	3	2025-11-04 21:39:35.212944	2025-11-05 08:00:09.191934	\N	\N	f	\N	t	4	f
817	https://www.r4.com/inversion-para-todos/como-invertir-en-agua-conoce-los-productos-financieros	508	3	2025-11-04 21:39:37.152478	2025-11-05 08:00:10.730475	\N	\N	f	\N	t	4	f
818	https://www.r4.com/inversion-para-todos/que-es-y-como-invertir-en-real-estate	508	3	2025-11-04 21:39:38.678871	2025-11-05 08:00:12.200025	\N	\N	f	\N	t	4	f
819	https://www.r4.com/inversion-para-todos/que-es-invertir-en-dividendos-y-como-hacerlo	508	3	2025-11-04 21:39:40.171787	2025-11-05 08:00:13.82996	\N	\N	f	\N	t	4	f
820	https://www.r4.com/inversion-para-todos/que-son-planes-de-pensiones	508	3	2025-11-04 21:39:41.685766	2025-11-05 08:00:15.412869	\N	\N	f	\N	t	4	f
822	https://www.r4.com/inversion-para-todos/category/invertir-tus-ahorros/page/7	508	3	2025-11-04 21:39:45.23113	2025-11-05 08:00:19.723519	\N	\N	f	\N	t	4	f
823	https://www.r4.com/inversion-para-todos/cinco-consejos-para-empezar-el-curso-laboral-con-buen-pie	509	3	2025-11-04 21:39:46.709468	2025-11-05 08:00:21.832693	\N	\N	f	\N	t	4	f
824	https://www.r4.com/inversion-para-todos/como-invertir-en-inteligencia-artificial	509	3	2025-11-04 21:39:48.170101	2025-11-05 08:00:23.52863	\N	\N	f	\N	t	4	f
825	https://www.r4.com/inversion-para-todos/que-es-el-sindrome-del-impostor	509	3	2025-11-04 21:39:49.655338	2025-11-05 08:00:25.420531	\N	\N	f	\N	t	4	f
826	https://www.r4.com/inversion-para-todos/como-descubrir-el-lado-oculto-de-las-noticias	509	3	2025-11-04 21:39:51.437105	2025-11-05 08:00:27.103648	\N	\N	f	\N	t	4	f
827	https://www.r4.com/inversion-para-todos/llena-tu-mochila-de-cursos	509	3	2025-11-04 21:39:52.92716	2025-11-05 08:00:28.65469	\N	\N	f	\N	t	4	f
828	https://www.r4.com/inversion-para-todos/consejos-cenas-navidad	509	3	2025-11-04 21:39:54.375789	2025-11-05 08:00:30.417568	\N	\N	f	\N	t	4	f
829	https://www.r4.com/inversion-para-todos/que-es-sindrome-postvacacional	509	3	2025-11-04 21:39:55.889916	2025-11-05 08:00:32.134138	\N	\N	f	\N	t	4	f
830	https://www.r4.com/inversion-para-todos/vuelta-a-la-oficina-tras-teletrabajo	509	3	2025-11-04 21:39:57.436256	2025-11-05 08:00:34.286582	\N	\N	f	\N	t	4	f
831	https://www.r4.com/inversion-para-todos/que-es-calistenia	509	3	2025-11-04 21:39:58.968295	2025-11-05 08:00:36.528413	\N	\N	f	\N	t	4	f
832	https://www.r4.com/inversion-para-todos/que-es-mindfulness	509	3	2025-11-04 21:40:00.492946	2025-11-05 08:00:38.563554	\N	\N	f	\N	t	4	f
833	https://www.r4.com/inversion-para-todos/como-mejorar-tu-productividad-teletrabajando	509	3	2025-11-04 21:40:02.178947	2025-11-05 08:00:40.122008	\N	\N	f	\N	t	4	f
834	https://www.r4.com/inversion-para-todos/consejos-contra-insomnio	509	3	2025-11-04 21:40:03.793371	2025-11-05 08:00:41.836647	\N	\N	f	\N	t	4	f
836	https://www.r4.com/inversion-para-todos/consejos-quitar-adiccion-movil	509	3	2025-11-04 21:40:07.155648	2025-11-05 08:00:46.30373	\N	\N	f	\N	t	4	f
837	https://www.r4.com/inversion-para-todos/importancia-psicologia-inversion	509	3	2025-11-04 21:40:08.702772	2025-11-05 08:00:48.00922	\N	\N	f	\N	t	4	f
838	https://www.r4.com/inversion-para-todos/consejos-para-teletrabajar	509	3	2025-11-04 21:40:10.224546	2025-11-05 08:00:49.562329	\N	\N	f	\N	t	4	f
839	https://www.r4.com/inversion-para-todos/que-es-slow-finance	509	3	2025-11-04 21:40:11.768992	2025-11-05 08:00:52.209865	\N	\N	f	\N	t	4	f
840	https://www.r4.com/inversion-para-todos/batch-cooking	509	3	2025-11-04 21:40:13.233433	2025-11-05 08:00:53.904116	\N	\N	f	\N	t	4	f
841	https://www.r4.com/inversion-para-todos/consejos-evitar-compras-compulsivas	509	3	2025-11-04 21:40:14.736906	2025-11-05 08:00:55.479119	\N	\N	f	\N	t	4	f
842	https://www.r4.com/inversion-para-todos/evitar-lesiones-oficina	509	3	2025-11-04 21:40:16.387083	2025-11-05 08:00:56.914255	\N	\N	f	\N	t	4	f
843	https://www.r4.com/inversion-para-todos/no-solo-de-pan-vive-el-hombre	509	3	2025-11-04 21:40:18.012944	2025-11-05 08:00:58.423874	\N	\N	f	\N	t	4	f
844	https://www.r4.com/inversion-para-todos/category/invertir-en-ti/page/2	509	3	2025-11-04 21:40:19.541971	2025-11-05 08:01:00.091286	\N	\N	f	\N	t	4	f
845	https://www.r4.com/inversion-para-todos/cuantos-mercados-financieros-existen	510	3	2025-11-04 21:40:21.091914	2025-11-05 08:01:01.739161	\N	\N	f	\N	t	4	f
846	https://www.r4.com/inversion-para-todos/como-medir-rentabilidad-inversion	510	3	2025-11-04 21:40:22.773837	2025-11-05 08:01:03.243225	\N	\N	f	\N	t	4	f
847	https://www.r4.com/inversion-para-todos/historia-bolsa-mercados-bursatiles	510	3	2025-11-04 21:40:24.219513	2025-11-05 08:01:04.723118	\N	\N	f	\N	t	4	f
849	https://www.r4.com/inversion-para-todos/que-es-el-interes-compuesto	510	3	2025-11-04 21:40:27.455861	2025-11-05 08:01:08.200784	\N	\N	f	\N	t	4	f
850	https://www.r4.com/inversion-para-todos/que-es-la-gestion-pasiva	511	3	2025-11-04 21:40:28.920017	2025-11-05 08:01:09.906296	\N	\N	f	\N	t	4	f
851	https://www.r4.com/servicios-gestion/servicios-r4-activa/r4-activa-etfs	511	3	2025-11-04 21:40:30.393744	2025-11-05 08:01:11.491806	\N	\N	f	\N	t	4	f
852	https://www.r4.com/inversion-para-todos/que-es-el-valor-liquidativo-de-un-fondo-de-inversion	511	3	2025-11-04 21:40:31.840725	2025-11-05 08:01:12.744154	\N	\N	f	\N	t	4	f
1098	https://www.r4.com/articulos-y-analisis/valores/tubacex-revision-de-objetivos-ante-una-incertidumbre-persistente	690	4	2025-11-04 21:46:50.728649	2025-11-05 08:07:14.840338	\N	\N	f	\N	t	4	f
854	https://www.r4.com/inversion-para-todos/que-es-gap-en-bolsa	512	3	2025-11-04 21:40:34.713464	2025-11-05 08:01:16.358794	\N	\N	f	\N	t	4	f
855	https://www.r4.com/inversion-para-todos/concretar-el-objeto-social-de-una-empresa	513	3	2025-11-04 21:40:36.253442	2025-11-05 08:01:17.867727	\N	\N	f	\N	t	4	f
857	https://www.r4.com/inversion-para-todos/impuestos-directos-e-indirectos-caracteristicas-y-tipos	514	3	2025-11-04 21:40:39.612433	2025-11-05 08:01:21.371363	\N	\N	f	\N	t	4	f
858	https://www.r4.com/inversion-para-todos/declaracion-renta-fiscalidad-inversion	514	3	2025-11-04 21:40:41.054494	2025-11-05 08:01:23.347481	\N	\N	f	\N	t	4	f
859	https://www.r4.com/inversion-para-todos/diferencia-entre-acciones-y-bonos	514	3	2025-11-04 21:40:42.552867	2025-11-05 08:01:25.02844	\N	\N	f	\N	t	4	f
860	https://www.r4.com/inversion-para-todos/que-son-los-fondos-de-inversion	514	3	2025-11-04 21:40:44.031253	2025-11-05 08:01:26.778069	\N	\N	f	\N	t	4	f
861	https://www.r4.com/inversion-para-todos/que-tipos-de-activos-financieros-existen	514	3	2025-11-04 21:40:45.963457	2025-11-05 08:01:28.437661	\N	\N	f	\N	t	4	f
862	https://www.r4.com/inversion-para-todos/que-es-inversion-socialmente-responsable	516	3	2025-11-04 21:40:47.66592	2025-11-05 08:01:30.046295	\N	\N	f	\N	t	4	f
863	https://www.r4.com/inversion-para-todos/la-importancia-de-los-criterios-esg-en-la-inversion	516	3	2025-11-04 21:40:49.149062	2025-11-05 08:01:31.611356	\N	\N	f	\N	t	4	f
864	https://www.r4.com/inversion-para-todos/como-mitigar-la-volatilidad	516	3	2025-11-04 21:40:50.984259	2025-11-05 08:01:33.772643	\N	\N	f	\N	t	4	f
865	https://www.r4.com/inversion-para-todos/introduccion-bolsa	517	3	2025-11-04 21:40:52.658403	2025-11-05 08:01:35.440873	\N	\N	f	\N	t	4	f
866	https://www.r4.com/inversion-para-todos/que-es-circuit-breaker-en-bolsa	517	3	2025-11-04 21:40:54.139913	2025-11-05 08:01:37.444834	\N	\N	f	\N	t	4	f
867	https://www.r4.com/inversion-para-todos/tipo-de-inversores	518	3	2025-11-04 21:40:55.551389	2025-11-05 08:01:38.996431	\N	\N	f	\N	t	4	f
868	https://www.r4.com/serviciosr4/etftop-plataforma-online-operar-con-etfs	518	3	2025-11-04 21:40:57.03364	2025-11-05 08:01:40.478119	\N	\N	f	\N	t	4	f
869	https://www.r4.com/inversion-para-todos/diversificar-inversiones-beneficios-y-desventajas	518	3	2025-11-04 21:40:58.467281	2025-11-05 08:01:41.925746	\N	\N	f	\N	t	4	f
871	https://www.r4.com/inversion-para-todos/que-es-la-desinflacion	519	3	2025-11-04 21:41:01.851746	2025-11-05 08:01:45.951799	\N	\N	f	\N	t	4	f
872	https://www.r4.com/inversion-para-todos/invertir-en-deuda-publica	519	3	2025-11-04 21:41:03.311098	2025-11-05 08:01:47.677041	\N	\N	f	\N	t	4	f
874	https://www.r4.com/articulos-y-analisis/noticias-renta4/el-sueno-de-nirina-la-opera-de-madagascar-que-transforma-vidas-infantiles	522	3	2025-11-04 21:41:06.977559	2025-11-05 08:01:51.774563	\N	\N	f	\N	t	4	f
875	https://www.r4.com/autor/dpto-comunicacion	523	3	2025-11-04 21:41:08.174524	2025-11-05 08:01:52.967641	\N	\N	f	\N	t	4	f
876	https://www.r4.com/autor/r4gestora	527	3	2025-11-04 21:41:09.458098	2025-11-05 08:01:54.32997	\N	\N	f	\N	t	4	f
878	https://www.r4.com/articulos-y-analisis/noticias-renta4/asesoramiento-a-grupo-perez-y-cia-en-la-fusion-de-su-negocio-logistico-con-martico-valencia	532	3	2025-11-04 21:41:11.982837	2025-11-05 08:01:57.479375	\N	\N	f	\N	t	4	f
879	https://www.r4.com/articulos-y-analisis/noticias-renta4/admision-de-cirsa-a-cotizacion-en-la-bolsa-de-valores-espanola	532	3	2025-11-04 21:41:13.178412	2025-11-05 08:01:59.79202	\N	\N	f	\N	t	4	f
880	https://www.r4.com/articulos-y-analisis/noticias-renta4/marcos-pastor-se-incorpora-a-renta-4-banco-como-maximo-responsable-de-tecnologia	532	3	2025-11-04 21:41:14.402305	2025-11-05 08:02:02.358632	\N	\N	f	\N	t	4	f
881	https://www.r4.com/articulos-y-analisis/noticias-renta4/asesoramiento-a-aspasia-en-la-incorporacion-de-growth-partners-capital-a-su-accionariado	532	3	2025-11-04 21:41:15.580083	2025-11-05 08:02:04.544952	\N	\N	f	\N	t	4	f
882	https://www.r4.com/articulos-y-analisis/noticias-renta4/el-fondo-de-inversion-renta-4-renta-fija-6-meses-supera-el-hito-de-los-1-000-millones-de-euros-en-patrimonio	532	3	2025-11-04 21:41:16.752116	2025-11-05 08:02:06.869004	\N	\N	f	\N	t	4	f
883	https://www.r4.com/articulos-y-analisis/noticias-renta4/el-festival-internacional-de-musica-y-danza-en-granada	532	3	2025-11-04 21:41:17.93361	2025-11-05 08:02:08.014005	\N	\N	f	\N	t	4	f
884	https://www.r4.com/articulos-y-analisis/noticias-renta4/antonio-carmona-visita-el-taller-de-musica-inclusiva-de-la-fundacion-sese-reforzando-su-apuesta-por-la-inclusion-social	532	3	2025-11-04 21:41:19.10124	2025-11-05 08:02:10.245267	\N	\N	f	\N	t	4	f
885	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-banco-celebra-finfluencers-2025-y-une-a-mas-de-1-000-asistentes-en-directo-junto-a-algunos-de-los-principales-creadores-de-contenido-financiero	532	3	2025-11-04 21:41:20.292227	2025-11-05 08:02:11.400462	\N	\N	f	\N	t	4	f
886	https://www.r4.com/articulos-y-analisis/area-prensa/3	532	3	2025-11-04 21:41:21.485914	2025-11-05 08:02:12.548592	\N	\N	f	\N	t	4	f
887	https://www.r4.com/analisis-actualidad/invierte-en-nuestro-entorno	537	3	2025-11-04 21:41:22.677832	2025-11-05 08:02:14.614805	\N	\N	f	\N	t	4	f
888	https://www.r4.com/analisis-actualidad/opinion-expertos/sostenibilidad-con-la-vista-puesta-en-el-futuro	537	3	2025-11-04 21:41:23.943356	2025-11-05 08:02:15.802629	\N	\N	f	\N	t	4	f
889	http://www.r4.com/portal?TX=goto&FWD=MAIN10	540	3	2025-11-04 21:41:25.144401	2025-11-05 08:02:17.02773	\N	\N	f	\N	t	4	f
890	http://www.r4.com/broker-online/productos-de-inversion/bolsa	540	3	2025-11-04 21:41:26.319986	2025-11-05 08:02:18.180632	\N	\N	f	\N	t	4	f
891	http://www.r4.com/fondos-de-inversion/seleccion50	540	3	2025-11-04 21:41:27.542793	2025-11-05 08:02:19.43379	\N	\N	f	\N	t	4	f
892	http://www.r4.com/que-necesitas/red-oficinas	540	3	2025-11-04 21:41:30.687569	2025-11-05 08:02:21.402443	\N	\N	f	\N	t	4	f
893	http://www.r4.com/que-necesitas/especialista-inversion	540	3	2025-11-04 21:41:31.903546	2025-11-05 08:02:22.60566	\N	\N	f	\N	t	4	f
894	http://www.r4.com/contacto	540	3	2025-11-04 21:41:33.143403	2025-11-05 08:02:23.903886	\N	\N	f	\N	t	4	f
895	http://www.r4.com/fondos-de-inversion	540	3	2025-11-04 21:41:34.364878	2025-11-05 08:02:25.137469	\N	\N	f	\N	t	4	f
896	http://www.r4.com/soluciones-easy/carteras-easy	540	3	2025-11-04 21:41:35.555202	2025-11-05 08:02:26.328683	\N	\N	f	\N	t	4	f
897	http://www.r4.com/tarifas	540	3	2025-11-04 21:41:36.921379	2025-11-05 08:02:27.655661	\N	\N	f	\N	t	4	f
898	http://www.r4.com/carteras-gestionadas/carteras-de-fondos	540	3	2025-11-04 21:41:38.196365	2025-11-05 08:02:28.841877	\N	\N	f	\N	t	4	f
899	http://www.r4.com/asesoramiento	540	3	2025-11-04 21:41:39.431303	2025-11-05 08:02:30.066047	\N	\N	f	\N	t	4	f
900	http://www.r4.com/broker-online	540	3	2025-11-04 21:41:40.725092	2025-11-05 08:02:31.454717	\N	\N	f	\N	t	4	f
901	http://www.r4.com/renta-fija	540	3	2025-11-04 21:41:41.993438	2025-11-05 08:02:33.843975	\N	\N	f	\N	t	4	f
902	http://www.r4.com/broker-online/productos-de-inversion/etfs	540	3	2025-11-04 21:41:43.294953	2025-11-05 08:02:35.078258	\N	\N	f	\N	t	4	f
903	http://www.r4.com/carteras-gestionadas/gestion-personalizada	540	3	2025-11-04 21:41:44.54269	2025-11-05 08:02:36.382496	\N	\N	f	\N	t	4	f
904	https://www.r4.com/articulos-y-analisis/valores/sector-financiero-previo-3t25-entorno-favorable-para-unos-buenos-resultados	544	4	2025-11-04 21:41:45.758625	2025-11-05 08:02:37.58782	\N	\N	f	\N	t	4	f
990	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-4t24-el-mercado-reconoce-su-gran-transformacion-y-el-fortalecimiento-de-su-posicion-estrategica-y-situacion-financiera	554	4	2025-11-04 21:44:16.698432	2025-11-05 08:04:42.005791	\N	\N	f	\N	t	4	f
1603	https://www.r4.com/articulos-y-analisis/valores/solaria-4t23-tras-3-anos-historicos-solaria-se-enfrenta-a-la-normalizacion-del-precio-de-la-energia	1129	5	2025-11-04 22:00:25.094301	2025-11-05 08:21:58.001298	\N	\N	f	\N	t	4	f
906	https://www.r4.com/articulos-y-analisis/valores/sabadell-baja-aceptacion-de-la-opa-por-parte-de-los-accionistas-de-sabadell	544	4	2025-11-04 21:41:48.129803	2025-11-05 08:02:40.020743	\N	\N	f	\N	t	4	f
907	https://www.r4.com/articulos-y-analisis/valores/opa-bbva-sabadell-mejora-de-la-oferta	544	4	2025-11-04 21:41:49.28323	2025-11-05 08:02:41.236308	\N	\N	f	\N	t	4	f
908	https://www.r4.com/articulos-y-analisis/valores/bbva-modifica-la-oferta-por-sabadell	544	4	2025-11-04 21:41:50.463789	2025-11-05 08:02:42.489887	\N	\N	f	\N	t	4	f
909	https://www.r4.com/articulos-y-analisis/valores/sector-financiero-s-p-mejora-del-rating-de-los-bancos-espanoles	544	4	2025-11-04 21:41:51.626503	2025-11-05 08:02:43.748723	\N	\N	f	\N	t	4	f
910	https://www.r4.com/articulos-y-analisis/valores/opa-bbva-sabadell-recta-final-de-la-oferta	544	4	2025-11-04 21:41:52.823033	2025-11-05 08:02:44.989076	\N	\N	f	\N	t	4	f
911	https://www.r4.com/articulos-y-analisis/valores/bbva-2t25-mejora-guias-2025-y-presenta-objetivos-2025-28	544	4	2025-11-04 21:41:55.018561	2025-11-05 08:02:46.188863	\N	\N	f	\N	t	4	f
912	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0113211835/2	544	4	2025-11-04 21:41:56.24662	2025-11-05 08:02:47.394602	\N	\N	f	\N	t	4	f
914	https://www.r4.com/articulos-y-analisis/valores/enagas-previo-9m25-previsiblemente-alineados-para-alcanzar-objetivos	545	4	2025-11-04 21:41:59.370042	2025-11-05 08:02:49.816756	\N	\N	f	\N	t	4	f
915	https://www.r4.com/articulos-y-analisis/valores/enagas-1s25-resultado-neto-beneficiado-por-extraordinarios-pero-sin-efecto-en-flujo-de-caja	545	4	2025-11-04 21:42:01.567418	2025-11-05 08:02:50.997805	\N	\N	f	\N	t	4	f
916	https://www.r4.com/articulos-y-analisis/valores/enagas-previo-1s25-pendientes-de-comentarios-sobre-el-borrador-de-la-regulacion-2027-2032	545	4	2025-11-04 21:42:02.76422	2025-11-05 08:02:52.203007	\N	\N	f	\N	t	4	f
917	https://www.r4.com/articulos-y-analisis/valores/enagas-1t25-bdi-supera-previsiones-pero-reiteran-objetivos	545	4	2025-11-04 21:42:03.994162	2025-11-05 08:02:53.44528	\N	\N	f	\N	t	4	f
918	https://www.r4.com/articulos-y-analisis/valores/enagas-previo-1t25-resultados-a-la-baja-esperando-visibilidad-de-l-p-a-lo-largo-del-ano	545	4	2025-11-04 21:42:06.284529	2025-11-05 08:02:54.648849	\N	\N	f	\N	t	4	f
919	https://www.r4.com/articulos-y-analisis/valores/enagas-negocio-de-gas-infravalorado-crecimiento-en-hidrogeno-desde-2026	545	4	2025-11-04 21:42:08.545987	2025-11-05 08:02:55.87261	\N	\N	f	\N	t	4	f
920	https://www.r4.com/articulos-y-analisis/valores/conclusiones-enagas-2024-pendientes-todavia-de-la-resolucion-de-algunas-incertidumbres	545	4	2025-11-04 21:42:09.746986	2025-11-05 08:02:57.07438	\N	\N	f	\N	t	4	f
921	https://www.r4.com/articulos-y-analisis/valores/enagas-2024-por-encima-de-objetivos-anuncia-un-reducido-programa-de-recompra-de-acciones	545	4	2025-11-04 21:42:11.922227	2025-11-05 08:02:58.291555	\N	\N	f	\N	t	4	f
922	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0130960018/2	545	4	2025-11-04 21:42:14.202928	2025-11-05 08:02:59.506478	\N	\N	f	\N	t	4	f
924	https://www.r4.com/articulos-y-analisis/valores/aena-9m25-cuenta-de-resultados-alineados-con-previsiones-deuda-neta-mejor-evolucion	546	4	2025-11-04 21:42:17.447369	2025-11-05 08:03:01.917818	\N	\N	f	\N	t	4	f
925	https://www.r4.com/articulos-y-analisis/valores/redeia-9m25-sin-sorpresas	546	4	2025-11-04 21:42:18.644017	2025-11-05 08:03:03.155727	\N	\N	f	\N	t	4	f
926	https://www.r4.com/articulos-y-analisis/valores/endesa-9m25-mejoran-expectativas-pero-guia-sin-cambios-esperada-parte-alta-del-rango	547	4	2025-11-04 21:42:20.83638	2025-11-05 08:03:04.388676	\N	\N	f	\N	t	4	f
927	https://www.r4.com/articulos-y-analisis/valores/previo-endesa-9m25-pendientes-de-comentarios-sobre-posible-revision-regulatoria	547	4	2025-11-04 21:42:22.032575	2025-11-05 08:03:05.629295	\N	\N	f	\N	t	4	f
928	https://www.r4.com/articulos-y-analisis/valores/sector-electrico-no-sale-adelante-la-aprobacion-del-decreto-antiapagones-en-el-congreso	547	4	2025-11-04 21:42:24.233468	2025-11-05 08:03:06.891694	\N	\N	f	\N	t	4	f
929	https://www.r4.com/articulos-y-analisis/valores/previo-endesa-1s25-el-foco-en-la-conferencia	547	4	2025-11-04 21:42:26.494585	2025-11-05 08:03:08.1281	\N	\N	f	\N	t	4	f
930	https://www.r4.com/articulos-y-analisis/valores/endesa-1t25-superan-previsiones-pero-reiteran-objetivos	547	4	2025-11-04 21:42:28.777752	2025-11-05 08:03:09.377845	\N	\N	f	\N	t	4	f
931	https://www.r4.com/articulos-y-analisis/valores/previo-endesa-1t25-deuda-al-alza-por-compras-buena-marcha-operativa-prevista	547	4	2025-11-04 21:42:29.943421	2025-11-05 08:03:10.632123	\N	\N	f	\N	t	4	f
932	https://www.r4.com/articulos-y-analisis/valores/endesa-reducimos-a-mantener-a-la-espera-de-potencial-mejora-de-estimaciones	547	4	2025-11-04 21:42:31.147766	2025-11-05 08:03:11.838459	\N	\N	f	\N	t	4	f
933	https://www.r4.com/articulos-y-analisis/valores/endesa-2024-p-l-por-encima-de-expectativas	547	4	2025-11-04 21:42:32.308315	2025-11-05 08:03:13.071124	\N	\N	f	\N	t	4	f
934	https://www.r4.com/articulos-y-analisis/valores/previo-endesa-2024-esperamos-que-se-alcancen-las-guias-2024-y-la-deuda-neta-se-situe-en-la-parte-baja-del-rango-objetivo	547	4	2025-11-04 21:42:33.480022	2025-11-05 08:03:14.361287	\N	\N	f	\N	t	4	f
935	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0130670112/2	547	4	2025-11-04 21:42:34.703179	2025-11-05 08:03:15.534439	\N	\N	f	\N	t	4	f
936	https://www.r4.com/articulos-y-analisis/valores/ferrovial-9m25-p-l-en-linea-caja-mejora-nuestra-prevision	548	4	2025-11-04 21:42:35.904004	2025-11-05 08:03:16.772981	\N	\N	f	\N	t	4	f
937	https://www.r4.com/articulos-y-analisis/valores/ferrovial-previo-9m25-esperamos-que-continue-la-fortaleza-en-autopistas	548	4	2025-11-04 21:42:37.060438	2025-11-05 08:03:17.97101	\N	\N	f	\N	t	4	f
938	https://www.r4.com/articulos-y-analisis/valores/ferrovial-la-etr-407-sigue-mejorando-su-desempeno	548	4	2025-11-04 21:42:38.211932	2025-11-05 08:03:19.20399	\N	\N	f	\N	t	4	f
939	https://www.r4.com/articulos-y-analisis/valores/ferrovial-previo-1s25-pendientes-de-los-comentarios-respecto-a-la-evolucion-del-dolar	548	4	2025-11-04 21:42:39.38053	2025-11-05 08:03:20.46188	\N	\N	f	\N	t	4	f
940	https://www.r4.com/articulos-y-analisis/valores/ferrovial-1t25-la-operativa-sigue-evolucionando-positivamente-superando-previsiones	548	4	2025-11-04 21:42:41.451362	2025-11-05 08:03:21.639272	\N	\N	f	\N	t	4	f
941	https://www.r4.com/articulos-y-analisis/valores/ferrovial-previo-1t25-esperamos-que-la-operativa-siga-mejorando	548	4	2025-11-04 21:42:43.684022	2025-11-05 08:03:23.761605	\N	\N	f	\N	t	4	f
942	https://www.r4.com/articulos-y-analisis/valores/ferrovial-excelente-posicionamiento-para-seguir-ampliando-su-cartera-de-activos	548	4	2025-11-04 21:42:44.889375	2025-11-05 08:03:25.989341	\N	\N	f	\N	t	4	f
944	https://www.r4.com/articulos-y-analisis/valores/ferrovial-vende-la-participacion-restante-de-heathrow	548	4	2025-11-04 21:42:49.491528	2025-11-05 08:03:30.303492	\N	\N	f	\N	t	4	f
945	https://www.r4.com/articulos-y-analisis/valores/MCO+NL0015001FS8/2	548	4	2025-11-04 21:42:51.858239	2025-11-05 08:03:32.646464	\N	\N	f	\N	t	4	f
946	https://www.r4.com/articulos-y-analisis/valores/nextil-firma-del-mayor-contrato-de-la-historia-de-la-compania	549	4	2025-11-04 21:42:53.85139	2025-11-05 08:03:34.67159	\N	\N	f	\N	t	4	f
962	https://www.r4.com/articulos-y-analisis/valores/rovi-pre-4t24-menores-ingresos-y-mayores-gastos-no-combinan-bien	550	4	2025-11-04 21:43:25.951356	2025-11-05 08:03:59.582721	\N	\N	f	\N	t	4	f
963	https://www.r4.com/articulos-y-analisis/valores/rovi-profit-warning	550	4	2025-11-04 21:43:28.351195	2025-11-05 08:04:00.754865	\N	\N	f	\N	t	4	f
964	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0157261019/2	550	4	2025-11-04 21:43:30.652286	2025-11-05 08:04:01.887678	\N	\N	f	\N	t	4	f
965	https://www.r4.com/articulos-y-analisis/valores/atresmedia-la-debilidad-del-mercado-publicitario-nos-lleva-a-revisar-estimaciones	551	4	2025-11-04 21:43:32.81649	2025-11-05 08:04:03.072744	\N	\N	f	\N	t	4	f
967	https://www.r4.com/articulos-y-analisis/valores/mapfre-1t25-buenas-tendencias-apoyan-la-mejora-de-objetivos-del-plan-estrategico	552	4	2025-11-04 21:43:36.043914	2025-11-05 08:04:05.472254	\N	\N	f	\N	t	4	f
968	https://www.r4.com/articulos-y-analisis/valores/mapfre-eficiencia-y-gestion-de-la-siniestralidad-claves-para-el-roe	552	4	2025-11-04 21:43:38.345384	2025-11-05 08:04:06.612976	\N	\N	f	\N	t	4	f
969	https://www.r4.com/articulos-y-analisis/valores/mapfre-las-subidas-de-tarifas-y-la-gestion-de-la-siniestralidad-les-permite-ser-optimistas-de-cara-a-2025	552	4	2025-11-04 21:43:40.501364	2025-11-05 08:04:08.691109	\N	\N	f	\N	t	4	f
970	https://www.r4.com/articulos-y-analisis/valores/mapfre-2024-buen-punto-de-partida-para-el-cumplimiento-de-los-objetivos-2024-26	552	4	2025-11-04 21:43:42.843829	2025-11-05 08:04:09.90785	\N	\N	f	\N	t	4	f
971	https://www.r4.com/articulos-y-analisis/valores/mapfre-3t24-continua-la-mejora-de-la-rentabilidad-sobreponderar-p-o-2-27-eur-acc	552	4	2025-11-04 21:43:45.197176	2025-11-05 08:04:12.206602	\N	\N	f	\N	t	4	f
972	https://www.r4.com/articulos-y-analisis/valores/mapfre-resultados-1s24-se-mantiene-el-ritmo-de-mejora-de-la-rentabilidad-tecnica-mantener-p-o-2-27-eur-acc	552	4	2025-11-04 21:43:47.44763	2025-11-05 08:04:13.362457	\N	\N	f	\N	t	4	f
973	https://www.r4.com/articulos-y-analisis/valores/mapfre-resultados-1t24-beneficio-neto-impulsado-por-la-mejora-de-la-rentabilidad-tecnica-mantener-p-o-2-27-eur-acc	552	4	2025-11-04 21:43:49.706032	2025-11-05 08:04:14.535997	\N	\N	f	\N	t	4	f
974	https://www.r4.com/articulos-y-analisis/valores/mapfre-2023-el-crecimiento-en-ingresos-apoya-la-mejora-del-roe	552	4	2025-11-04 21:43:51.982604	2025-11-05 08:04:16.916837	\N	\N	f	\N	t	4	f
975	https://www.r4.com/articulos-y-analisis/valores/sacyr-obtiene-investment-grade-por-parte-de-dbrs	553	4	2025-11-04 21:43:54.311511	2025-11-05 08:04:18.082004	\N	\N	f	\N	t	4	f
976	https://www.r4.com/articulos-y-analisis/valores/previo-sacyr-1s25-buena-evolucion-trimestral-alineada-con-la-tendencia-anterior	553	4	2025-11-04 21:43:56.445807	2025-11-05 08:04:19.213156	\N	\N	f	\N	t	4	f
1190	https://www.r4.com/inversion-para-todos/que-son-las-letras-del-tesoro	795	4	2025-11-04 21:48:56.847974	2025-11-05 08:09:16.491976	\N	\N	f	\N	t	4	f
977	https://www.r4.com/articulos-y-analisis/valores/sacyr-el-potencial-todavia-es-atractivo-seguimos-pendientes-de-catalizadores	553	4	2025-11-04 21:43:58.81319	2025-11-05 08:04:20.385575	\N	\N	f	\N	t	4	f
1616	https://www.r4.com/articulos-y-analisis/valores/vidrala-1t25-la-evolucion-del-margen-compensa-la-debilidad-de-la-demanda	1131	5	2025-11-04 22:00:51.312868	2025-11-05 08:22:13.305122	\N	\N	f	\N	t	4	f
948	https://www.r4.com/articulos-y-analisis/valores/previo-inditex-recuperacion-del-crecimiento-de-ventas-a-niveles-mas-normalizados-el-impacto-negativo-de-la-divisa-continua	549	4	2025-11-04 21:42:57.282289	2025-11-05 08:03:38.48453	\N	\N	f	\N	t	4	f
949	https://www.r4.com/articulos-y-analisis/valores/inditex-previo-mejor-evolucion-prevista-en-la-segunda-mitad-del-trimestre	549	4	2025-11-04 21:42:59.532236	2025-11-05 08:03:39.680164	\N	\N	f	\N	t	4	f
950	https://www.r4.com/articulos-y-analisis/valores/inditex-resultados-4t-24-que-reflejan-una-mejor-evolucion-de-los-gastos-el-inicio-de-ventas-1t-25-muestra-una-mayor-ralentizacion-de-lo-esperado	549	4	2025-11-04 21:43:01.782126	2025-11-05 08:03:40.897951	\N	\N	f	\N	t	4	f
951	https://www.r4.com/articulos-y-analisis/valores/inditex-previo-4t-24-manteniendo-el-nivel-de-crecimiento-de-9m-24-sin-grandes-sorpresas-para-2025	549	4	2025-11-04 21:43:02.946735	2025-11-05 08:03:42.095219	\N	\N	f	\N	t	4	f
952	https://www.r4.com/articulos-y-analisis/valores/inditex-en-maximos-historicos	549	4	2025-11-04 21:43:05.192344	2025-11-05 08:03:43.300766	\N	\N	f	\N	t	4	f
953	https://www.r4.com/articulos-y-analisis/valores/inditex-resultados-3t24-incumplen-previsiones-en-las-principales-magnitudes-inicio-de-ventas-4t24-crecen-por-debajo-vs-9m24	549	4	2025-11-04 21:43:06.370507	2025-11-05 08:03:44.58849	\N	\N	f	\N	t	4	f
954	https://www.r4.com/articulos-y-analisis/valores/inditex-previo-3t-24-una-comparativa-menos-exigente-permite-acelerar-el-crecimiento-frente-a-1s-24-p-o-49-7-eur-mantener	549	4	2025-11-04 21:43:08.815839	2025-11-05 08:03:45.859103	\N	\N	f	\N	t	4	f
955	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0148396007/2	549	4	2025-11-04 21:43:10.97577	2025-11-05 08:03:47.116329	\N	\N	f	\N	t	4	f
956	https://www.r4.com/articulos-y-analisis/valores/rovi-alcanza-un-nuevo-acuerdo-para-la-fabricacion-de-un-nuevo-medicamento-de-roche	550	4	2025-11-04 21:43:13.093585	2025-11-05 08:03:49.269166	\N	\N	f	\N	t	4	f
957	https://www.r4.com/articulos-y-analisis/valores/rovi-adquiere-una-planta-de-fabricacion-de-farmacos-inyectables-en-estados-unidos	550	4	2025-11-04 21:43:15.527359	2025-11-05 08:03:51.488297	\N	\N	f	\N	t	4	f
958	https://www.r4.com/articulos-y-analisis/valores/rovi-pre-2t25-se-aprecia-mejora-con-respecto-al-trimestre-anterior	550	4	2025-11-04 21:43:17.70096	2025-11-05 08:03:52.67816	\N	\N	f	\N	t	4	f
959	https://www.r4.com/articulos-y-analisis/valores/rovi-la-fda-aprueba-la-vacuna-de-moderna-para-vrs-en-adultos-de-18-a-59-anos	550	4	2025-11-04 21:43:18.850993	2025-11-05 08:03:53.839462	\N	\N	f	\N	t	4	f
960	https://www.r4.com/articulos-y-analisis/valores/rovi-aprovechar-las-caidas-y-ser-paciente-los-resultados-vendran	550	4	2025-11-04 21:43:21.231091	2025-11-05 08:03:55.037006	\N	\N	f	\N	t	4	f
961	https://www.r4.com/articulos-y-analisis/valores/rovi-4t24-menor-actividad-en-el-trimestre	550	4	2025-11-04 21:43:23.591716	2025-11-05 08:03:57.249431	\N	\N	f	\N	t	4	f
978	https://www.r4.com/articulos-y-analisis/valores/sacyr-1t25-sin-sorpresas-no-esperamos-impacto-en-cotizacion	553	4	2025-11-04 21:44:01.037906	2025-11-05 08:04:21.582195	\N	\N	f	\N	t	4	f
979	https://www.r4.com/articulos-y-analisis/valores/previo-sacyr-1t25-el-primer-trimestre-suele-estar-condicionado-por-la-estacionalidad	553	4	2025-11-04 21:44:02.156921	2025-11-05 08:04:23.982432	\N	\N	f	\N	t	4	f
980	https://www.r4.com/articulos-y-analisis/valores/sacyr-positiva-vision-de-largo-plazo-con-importantes-catalizadores-a-corto	553	4	2025-11-04 21:44:04.407497	2025-11-05 08:04:25.15375	\N	\N	f	\N	t	4	f
981	https://www.r4.com/articulos-y-analisis/valores/sacyr-2024-encaminados-para-cumplir-con-los-objetivos-2027	553	4	2025-11-04 21:44:05.701481	2025-11-05 08:04:26.325547	\N	\N	f	\N	t	4	f
982	https://www.r4.com/articulos-y-analisis/valores/previo-sacyr-2024-seguimos-pendientes-de-la-rotacion-de-activos-en-colombia	553	4	2025-11-04 21:44:06.848928	2025-11-05 08:04:28.658971	\N	\N	f	\N	t	4	f
983	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0182870214/2	553	4	2025-11-04 21:44:08.284878	2025-11-05 08:04:29.819913	\N	\N	f	\N	t	4	f
984	https://www.r4.com/articulos-y-analisis/valores/sector-acero-nuevas-medidas-de-la-comision-europea-para-proteger-la-industria-del-acero	554	4	2025-11-04 21:44:09.700944	2025-11-05 08:04:31.946053	\N	\N	f	\N	t	4	f
985	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-nippon-steel-compra-us-steel	554	4	2025-11-04 21:44:10.861178	2025-11-05 08:04:33.096219	\N	\N	f	\N	t	4	f
986	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-posible-anuncio-de-acuerdo-nippon-steel-us-steel	554	4	2025-11-04 21:44:12.032484	2025-11-05 08:04:34.278854	\N	\N	f	\N	t	4	f
1659	https://www.r4.com/articulos-y-analisis/tecnico/ideas-corto-plazo-18-rovi-venta-60-euros-11-12	1149	5	2025-11-04 22:02:06.0487	2025-11-05 08:23:18.760486	\N	\N	f	\N	t	4	f
988	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-previo-1t-25-con-la-vista-puesta-en-los-aranceles-sin-signos-de-mejora-en-la-demanda-final	554	4	2025-11-04 21:44:14.369588	2025-11-05 08:04:38.694123	\N	\N	f	\N	t	4	f
989	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-anuncia-un-nuevo-plan-de-recompra-de-acciones	554	4	2025-11-04 21:44:15.529413	2025-11-05 08:04:39.833086	\N	\N	f	\N	t	4	f
991	https://www.r4.com/articulos-y-analisis/valores/MCO+LU1598757687/2	554	4	2025-11-04 21:44:17.896066	2025-11-05 08:04:44.301677	\N	\N	f	\N	t	4	f
992	https://www.r4.com/articulos-y-analisis/valores/cirsa-emision-de-bonos-por-importe-de-1-000-millones-de-euros	555	4	2025-11-04 21:44:19.066402	2025-11-05 08:04:45.53793	\N	\N	f	\N	t	4	f
993	https://www.r4.com/articulos-y-analisis/valores/cirsa-una-mina-de-oro-inicio-de-cobertura	555	4	2025-11-04 21:44:20.281725	2025-11-05 08:04:47.677253	\N	\N	f	\N	t	4	f
994	https://www.r4.com/articulos-y-analisis/valores/almirall-pre-2t25-sorprendidos-por-una-estimacion-de-consenso-que-preve-un-ebitda-practicamente-plano-en-el-trimestre	556	4	2025-11-04 21:44:21.441173	2025-11-05 08:04:48.915546	\N	\N	f	\N	t	4	f
995	https://www.r4.com/articulos-y-analisis/valores/almirall-1t25-positivas-cifras-impulsadas-por-el-fuerte-crecimiento-de-dermatologia-en-europa	556	4	2025-11-04 21:44:22.584833	2025-11-05 08:04:50.110028	\N	\N	f	\N	t	4	f
996	https://www.r4.com/articulos-y-analisis/valores/almirall-pre-1t25-con-ilumetri-cerca-de-su-pico-de-ventas-ebglyss-toma-el-relevo-e-impulsa-el-crecimiento	556	4	2025-11-04 21:44:23.798939	2025-11-05 08:04:51.324916	\N	\N	f	\N	t	4	f
997	https://www.r4.com/articulos-y-analisis/valores/almirall-ebglyss-definira-la-tendencia-de-los-proximos-anos	556	4	2025-11-04 21:44:24.959968	2025-11-05 08:04:52.540151	\N	\N	f	\N	t	4	f
998	https://www.r4.com/articulos-y-analisis/valores/almirall-4t24-acelera-el-crecimiento-y-anuncia-guias-por-encima-del-consenso	556	4	2025-11-04 21:44:26.125403	2025-11-05 08:04:53.735996	\N	\N	f	\N	t	4	f
999	https://www.r4.com/articulos-y-analisis/valores/almirall-pre-4t24-la-mayor-actividad-empieza-a-trasladarse-a-resultados	556	4	2025-11-04 21:44:27.304112	2025-11-05 08:04:54.989603	\N	\N	f	\N	t	4	f
1000	https://www.r4.com/articulos-y-analisis/valores/almirall-documentacion-de-la-43rd-jp-morgan-healthcare-conference-en-sf	556	4	2025-11-04 21:44:28.46212	2025-11-05 08:04:56.173063	\N	\N	f	\N	t	4	f
1001	https://www.r4.com/articulos-y-analisis/valores/almirall-2t24-en-linea-con-el-cumplimiento-de-los-objetivos-anuales	556	4	2025-11-04 21:44:29.648969	2025-11-05 08:04:57.366414	\N	\N	f	\N	t	4	f
1002	https://www.r4.com/articulos-y-analisis/valores/almirall-pre-2t24-la-clave-esta-en-el-exito-de-los-lanzamientos-de-ebglyss	556	4	2025-11-04 21:44:30.795317	2025-11-05 08:04:58.622964	\N	\N	f	\N	t	4	f
1003	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0157097017/2	556	4	2025-11-04 21:44:31.98142	2025-11-05 08:04:59.822292	\N	\N	f	\N	t	4	f
1004	https://www.r4.com/articulos-y-analisis/valores/iag-previo-3t-25-otra-temporada-de-verano-positivo-p-o-5-25-eur-sobreponderar	557	4	2025-11-04 21:44:33.166143	2025-11-05 08:05:01.083378	\N	\N	f	\N	t	4	f
1005	https://www.r4.com/articulos-y-analisis/valores/iag-dia-de-iberia	557	4	2025-11-04 21:44:34.337701	2025-11-05 08:05:02.315491	\N	\N	f	\N	t	4	f
1006	https://www.r4.com/articulos-y-analisis/valores/iag-enfoque-en-el-impacto-de-los-aranceles-en-trafico-y-reservas	557	4	2025-11-04 21:44:35.524475	2025-11-05 08:05:03.539412	\N	\N	f	\N	t	4	f
1007	https://www.r4.com/articulos-y-analisis/valores/previo-acs-1t25-buena-evolucion-operativa-prevista-deuda-neta-al-alza-por-estacionalidad	557	4	2025-11-04 21:44:36.682412	2025-11-05 08:05:04.765849	\N	\N	f	\N	t	4	f
1008	https://www.r4.com/articulos-y-analisis/valores/iag-crecimiento-mas-moderado-en-1t-25-y-entorno-ensombrecido-por-la-politica-arancelaria	557	4	2025-11-04 21:44:37.82716	2025-11-05 08:05:06.280887	\N	\N	f	\N	t	4	f
1009	https://www.r4.com/articulos-y-analisis/valores/iag-resultado-operativo-4t-24-supera-ampliamente-anuncia-un-plan-de-recompra-mas-ambicioso-esperamos-impacto-positivo	557	4	2025-11-04 21:44:38.999875	2025-11-05 08:05:07.471561	\N	\N	f	\N	t	4	f
1010	https://www.r4.com/articulos-y-analisis/valores/iag-crecimiento-mas-moderado-en-4t-24-y-buena-visibilidad-para-2025e	557	4	2025-11-04 21:44:40.161061	2025-11-05 08:05:08.698506	\N	\N	f	\N	t	4	f
1011	https://www.r4.com/articulos-y-analisis/valores/iag-anuncia-el-resultado-de-la-oferta-de-compra-de-bonos	557	4	2025-11-04 21:44:41.343184	2025-11-05 08:05:09.966517	\N	\N	f	\N	t	4	f
1012	https://www.r4.com/articulos-y-analisis/valores/iag-superando-niveles	557	4	2025-11-04 21:44:42.510062	2025-11-05 08:05:11.190624	\N	\N	f	\N	t	4	f
1013	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0177542018/2	557	4	2025-11-04 21:44:43.703338	2025-11-05 08:05:12.397502	\N	\N	f	\N	t	4	f
1015	https://www.r4.com/articulos-y-analisis/valores/merlin-properties-2t25-1s25-buenas-cifras-con-subida-de-guia-de-ffo-y-dpa	558	4	2025-11-04 21:44:46.089008	2025-11-05 08:05:14.867944	\N	\N	f	\N	t	4	f
1016	https://www.r4.com/articulos-y-analisis/valores/merlin-properties-previo-2t25-1s25-sin-sorpresas-y-pendientes-del-valor-de-los-activos	558	4	2025-11-04 21:44:47.259763	2025-11-05 08:05:16.067961	\N	\N	f	\N	t	4	f
1017	https://www.r4.com/articulos-y-analisis/valores/merlin-properties-previo-1t25-buenas-noticias-en-centros-de-datos	558	4	2025-11-04 21:44:48.41028	2025-11-05 08:05:17.247295	\N	\N	f	\N	t	4	f
1018	https://www.r4.com/articulos-y-analisis/valores/merlin-properties-un-2025-de-transicion-hacia-un-futuro-digital-y-rentable	558	4	2025-11-04 21:44:49.57621	2025-11-05 08:05:18.460715	\N	\N	f	\N	t	4	f
1019	https://www.r4.com/articulos-y-analisis/valores/merlin-properties-4t24-2024-supera-objetivo-de-ffo-0-55-eur-accion	558	4	2025-11-04 21:44:50.769647	2025-11-05 08:05:19.714928	\N	\N	f	\N	t	4	f
1020	https://www.r4.com/articulos-y-analisis/valores/merlin-properties-previo-4t24-2024-pendientes-de-cifra-final-de-ffo-y-valoracion-de-activos	558	4	2025-11-04 21:44:51.951658	2025-11-05 08:05:20.948496	\N	\N	f	\N	t	4	f
1021	https://www.r4.com/articulos-y-analisis/valores/merlin-properties-avanzando-hacia-un-futuro-digital-y-rentable	558	4	2025-11-04 21:44:53.104688	2025-11-05 08:05:22.144576	\N	\N	f	\N	t	4	f
1022	https://www.r4.com/articulos-y-analisis/valores/socimis-el-congreso-tumba-la-propuesta-de-cambio-en-el-regimen-fiscal-de-las-socimis	558	4	2025-11-04 21:44:54.289747	2025-11-05 08:05:23.330328	\N	\N	f	\N	t	4	f
1023	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105025003/2	558	4	2025-11-04 21:44:55.456923	2025-11-05 08:05:24.615783	\N	\N	f	\N	t	4	f
1024	https://www.r4.com/articulos-y-analisis/valores/colonial-entrevista-a-don-juan-jose-brugera-presidente-de-colonial	559	4	2025-11-04 21:44:56.649073	2025-11-05 08:05:25.843325	\N	\N	f	\N	t	4	f
1025	https://www.r4.com/articulos-y-analisis/valores/inmobiliaria-del-sur-previo-3t25-solidos-resultados-como-preludio-de-un-fuerte-4t25	559	4	2025-11-04 21:44:57.830309	2025-11-05 08:05:27.084011	\N	\N	f	\N	t	4	f
1026	https://www.r4.com/articulos-y-analisis/valores/metrovacesa-3t25-9m25-mejores-resultados-con-aumento-del-dividendo-y-mejora-de-guia	559	4	2025-11-04 21:44:58.988274	2025-11-05 08:05:28.270431	\N	\N	f	\N	t	4	f
1027	https://www.r4.com/autor/carmen-s-garcia	565	4	2025-11-04 21:45:00.176184	2025-11-05 08:05:29.48607	\N	\N	f	\N	t	4	f
1028	https://r4.com/portal?TX=goto&FWD=MAIN10	583	4	2025-11-04 21:45:01.345894	2025-11-05 08:05:30.732876	\N	\N	f	\N	t	4	f
1029	https://r4.com/articulos-y-analisis	583	4	2025-11-04 21:45:02.523833	2025-11-05 08:05:31.996296	\N	\N	f	\N	t	4	f
1458	https://www.r4.com/articulos-y-analisis/valores/telefonica-ingresos-y-ebitda-subyacente-cumplen-previsiones-de-consenso-deuda-neta-en-linea-encaminada-para-cumplir-con-los-objetivos-2025e	1043	5	2025-11-04 21:56:27.180313	2025-11-05 08:17:11.568925	\N	\N	f	\N	t	4	f
1033	https://r4.com/content/rentabanco/r4/es/normativa	595	4	2025-11-04 21:45:07.565685	2025-11-05 08:05:37.350523	\N	\N	f	\N	t	4	f
1036	https://www.r4.com/articulos-y-analisis/valores/telefonica-se-mantiene-la-tendencia-de-1s-25-enfoque-en-el-dia-del-inversor	605	4	2025-11-04 21:45:11.190687	2025-11-05 08:05:41.259627	\N	\N	f	\N	t	4	f
1037	https://www.r4.com/articulos-y-analisis/valores/telefonica-interes-en-alemania	605	4	2025-11-04 21:45:12.389102	2025-11-05 08:05:42.480985	\N	\N	f	\N	t	4	f
1038	https://www.r4.com/articulos-y-analisis/valores/telefonica-cierra-la-venta-de-telefonica-uruguay	605	4	2025-11-04 21:45:13.542815	2025-11-05 08:05:43.720996	\N	\N	f	\N	t	4	f
1039	https://www.r4.com/articulos-y-analisis/valores/telefonica-vodafone-espana-una-oportunidad-compleja	605	4	2025-11-04 21:45:14.705762	2025-11-05 08:05:44.975924	\N	\N	f	\N	t	4	f
1040	https://www.r4.com/articulos-y-analisis/valores/telefonica-segun-prensa-telefonica-esta-preparando-un-plan-de-bajas-voluntarias	605	4	2025-11-04 21:45:15.895694	2025-11-05 08:05:46.203703	\N	\N	f	\N	t	4	f
1041	https://www.r4.com/articulos-y-analisis/valores/telefonica-interes-oferta-por-telefonica-chile	605	4	2025-11-04 21:45:17.048745	2025-11-05 08:05:47.408809	\N	\N	f	\N	t	4	f
1042	https://www.r4.com/articulos-y-analisis/valores/telefonica-aprobacion-regulatoria-para-la-venta-de-telefonica-uruguay	605	4	2025-11-04 21:45:18.202761	2025-11-05 08:05:48.638286	\N	\N	f	\N	t	4	f
1043	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0178430E18/2	605	4	2025-11-04 21:45:19.373281	2025-11-05 08:05:49.835323	\N	\N	f	\N	t	4	f
1044	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/vuelve-el-atractivo-por-la-renta-fija	606	4	2025-11-04 21:45:20.536509	2025-11-05 08:05:51.090962	\N	\N	f	\N	t	4	f
1045	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/la-retirada-de-los-bancos-centrales-se-acelera-en-un-escenario-de-alta-incertidumbre	606	4	2025-11-04 21:45:21.710556	2025-11-05 08:05:52.276434	\N	\N	f	\N	t	4	f
1046	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/con-la-mirada-puesta-en-la-normalizacion-de-la-politica-monetaria	606	4	2025-11-04 21:45:22.866374	2025-11-05 08:05:53.500455	\N	\N	f	\N	t	4	f
1048	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/rotacion-sectorial-en-un-contexto-de-proximas-bajadas-de-tipos-de-interes	607	4	2025-11-04 21:45:25.322875	2025-11-05 08:05:55.954158	\N	\N	f	\N	t	4	f
1192	https://www.r4.com/inversion-para-todos/como-ahorrar-para-jubilacion	796	4	2025-11-04 21:48:59.4683	2025-11-05 08:09:19.269467	\N	\N	f	\N	t	4	f
1049	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/tecnologia-americana-1-riesgo-politico-frances-0	607	4	2025-11-04 21:45:26.473257	2025-11-05 08:05:57.14459	\N	\N	f	\N	t	4	f
1050	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/ciclo-resultados-empresariales-y-tipos-apoyan-a-las-bolsas-en-mayo	607	4	2025-11-04 21:45:27.658002	2025-11-05 08:05:58.32512	\N	\N	f	\N	t	4	f
1051	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/ajuste-adicional-de-expectativas-de-bajadas-de-tipos-y-riesgo-geopolitico-al-alza	607	4	2025-11-04 21:45:28.824522	2025-11-05 08:05:59.510053	\N	\N	f	\N	t	4	f
1052	https://www.r4.com/articulos-y-analisis/id/931145?utm_source=bdd_prensa&utm_medium=e-mail&utm_campaign=enviosprensa	612	4	2025-11-04 21:45:29.987613	2025-11-05 08:06:00.688938	\N	\N	f	\N	t	4	f
1053	https://www.r4.com/articulos-y-analisis/id/925446?utm_source=bdd_prensa&utm_medium=e-mail&utm_campaign=enviosprensa	618	4	2025-11-04 21:45:35.941024	2025-11-05 08:06:06.581509	\N	\N	f	\N	t	4	f
1054	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US22266M1045&MKT=MMN	660	4	2025-11-04 21:45:42.055378	2025-11-05 08:06:12.704399	\N	\N	f	\N	t	4	f
1055	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/como-invertir-en-inteligencia-artificial-desde-el-desarrollo-hasta-el-despliegue	661	4	2025-11-04 21:45:43.183407	2025-11-05 08:06:13.847113	\N	\N	f	\N	t	4	f
1056	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/tres-anos-invirtiendo-en-disrupcion-tecnologica-como-sera-el-futuro-actualidad-a-fondo	661	4	2025-11-04 21:45:44.365576	2025-11-05 08:06:15.114899	\N	\N	f	\N	t	4	f
1057	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/renta-4-acciones-globales-en-2023-actualidad-a-fondo	661	4	2025-11-04 21:45:45.515808	2025-11-05 08:06:16.346896	\N	\N	f	\N	t	4	f
1058	https://www.r4.com/articulos-y-analisis/ideas/revision-carteras-fondos-1S25	666	4	2025-11-04 21:45:46.736088	2025-11-05 08:06:17.537868	\N	\N	f	\N	t	4	f
1059	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/inversion-en-reits	667	4	2025-11-04 21:45:47.923719	2025-11-05 08:06:18.72302	\N	\N	f	\N	t	4	f
1060	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/inversion-en-empresas-relacionadas-con-la-seguridad	667	4	2025-11-04 21:45:49.099934	2025-11-05 08:06:19.947062	\N	\N	f	\N	t	4	f
1061	https://www.r4.com/articulos-y-analisis/ideas/impulso-sector-bancario-hasta-cuando	669	4	2025-11-04 21:45:51.357608	2025-11-05 08:06:21.173395	\N	\N	f	\N	t	4	f
1062	https://www.r4.com/articulos-y-analisis/ideas/estabilidad-europa-presion-eeuu-tensiones-francia	669	4	2025-11-04 21:45:53.711163	2025-11-05 08:06:22.354285	\N	\N	f	\N	t	4	f
1063	https://www.r4.com/articulos-y-analisis/ideas/por-que-invertir-periodicamente-funciona	669	4	2025-11-04 21:45:56.164271	2025-11-05 08:06:24.613103	\N	\N	f	\N	t	4	f
1064	https://www.r4.com/articulos-y-analisis/ideas/descubre-el-plan-easy-una-forma-sencilla-de-invertir	669	4	2025-11-04 21:45:57.32356	2025-11-05 08:06:27.101578	\N	\N	f	\N	t	4	f
1065	https://www.r4.com/articulos-y-analisis/ideas/construye-tu-futuro-con-el-ahorro-periodico-y-las-carteras-easy	669	4	2025-11-04 21:45:58.484115	2025-11-05 08:06:28.314904	\N	\N	f	\N	t	4	f
1066	https://www.r4.com/articulos-y-analisis/ideas/sabadell-entra-en-cartera	669	4	2025-11-04 21:45:59.661404	2025-11-05 08:06:29.551467	\N	\N	f	\N	t	4	f
1067	https://www.r4.com/articulos-y-analisis/ideas/cartera-tolerante-2025	669	4	2025-11-04 21:46:01.798023	2025-11-05 08:06:30.776411	\N	\N	f	\N	t	4	f
1068	https://www.r4.com/articulos-y-analisis/ideas/annus-horribilis-novo-nordisk	669	4	2025-11-04 21:46:04.14953	2025-11-05 08:06:32.975422	\N	\N	f	\N	t	4	f
1069	https://www.r4.com/articulos-y-analisis/ideas/pausa-politica-monetaria-entorno-incierto	669	4	2025-11-04 21:46:05.292399	2025-11-05 08:06:34.259436	\N	\N	f	\N	t	4	f
1070	https://www.r4.com/articulos-y-analisis/ideas/hbx-inditex-en-carteras-versatil-dividendo	669	4	2025-11-04 21:46:07.73934	2025-11-05 08:06:35.495247	\N	\N	f	\N	t	4	f
1071	https://www.r4.com/articulos-y-analisis/ideas/4	669	4	2025-11-04 21:46:08.877073	2025-11-05 08:06:36.718286	\N	\N	f	\N	t	4	f
1073	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/asoman-los-primeros-riesgos-pero-cambia-el-tono-de-las-bolsas	671	4	2025-11-04 21:46:12.656524	2025-11-05 08:06:40.213909	\N	\N	f	\N	t	4	f
1074	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/tras-un-agosto-fuerte-septiembre-empieza-con-demasiados-riesgos-latentes	671	4	2025-11-04 21:46:13.797008	2025-11-05 08:06:42.605647	\N	\N	f	\N	t	4	f
1075	https://www.r4.com/columnas-de-autores/vive-la-pasion-de-los-mercados/2	671	4	2025-11-04 21:46:15.930295	2025-11-05 08:06:43.827982	\N	\N	f	\N	t	4	f
1076	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-las-multiples-caras-del-oro-o-por-que-el-oro-puede-ser-alternativamente-activo-refugio-y-activo-de-riesgo	672	4	2025-11-04 21:46:17.05565	2025-11-05 08:06:45.060909	\N	\N	f	\N	t	4	f
1485	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/la-complacencia-es-el-primer-riesgo-de-las-bolsas-el-segundo-es-el-posicionamiento-bajista-extremo-sobre-el-dolar	1075	5	2025-11-04 21:57:00.771254	2025-11-05 08:18:14.403509	\N	\N	f	\N	t	4	f
1078	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-el-dolar-y-las-tormentas-de-verano	680	4	2025-11-04 21:46:21.402193	2025-11-05 08:06:47.514995	\N	\N	f	\N	t	4	f
1080	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/como-entender-las-stablecoins-de-forma-sencilla	681	4	2025-11-04 21:46:24.639618	2025-11-05 08:06:51.122414	\N	\N	f	\N	t	4	f
1081	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/noticias-desapercibidas-de-agosto-2025	681	4	2025-11-04 21:46:25.779685	2025-11-05 08:06:52.347426	\N	\N	f	\N	t	4	f
1082	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-nvidia-y-francia-sombras-en-la-tercera-fase	681	4	2025-11-04 21:46:28.160482	2025-11-05 08:06:53.555456	\N	\N	f	\N	t	4	f
1083	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/jackson-hole-confirma-el-control-de-trump-sobre-la-fed-y-las-bolsas-lo-celebran	681	4	2025-11-04 21:46:29.28765	2025-11-05 08:06:54.740441	\N	\N	f	\N	t	4	f
1084	https://www.r4.com/articulos-y-analisis/mercados/4	681	4	2025-11-04 21:46:31.505097	2025-11-05 08:06:55.982538	\N	\N	f	\N	t	4	f
1085	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0105777017	684	4	2025-11-04 21:46:33.652093	2025-11-05 08:06:57.208859	\N	\N	f	\N	t	4	f
1086	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0173516115	686	4	2025-11-04 21:46:35.598973	2025-11-05 08:06:59.302758	\N	\N	f	\N	t	4	f
1087	https://www.r4.com/articulos-y-analisis/valores/acerinox-previo-3t25-la-atencion-se-centrara-en-el-guidance-para-el-4t25	687	4	2025-11-04 21:46:37.850141	2025-11-05 08:07:01.454425	\N	\N	f	\N	t	4	f
1088	https://www.r4.com/articulos-y-analisis/valores/acerinox-2t25-perspectivas-3t25-en-el-rango-bajo-de-lo-esperado	687	4	2025-11-04 21:46:39.030576	2025-11-05 08:07:02.661784	\N	\N	f	\N	t	4	f
1089	https://www.r4.com/articulos-y-analisis/valores/acerinox-2t25e-en-linea-la-incertidumbre-resta-visibilidad-para-proximos-trimestres	687	4	2025-11-04 21:46:40.189934	2025-11-05 08:07:03.841666	\N	\N	f	\N	t	4	f
1090	https://www.r4.com/articulos-y-analisis/valores/acerinox-no-descarta-cotizar-en-estados-unidos	687	4	2025-11-04 21:46:41.370759	2025-11-05 08:07:05.020914	\N	\N	f	\N	t	4	f
1091	https://www.r4.com/articulos-y-analisis/valores/acerinox-1t25-ligeramente-peor-de-lo-esperado-guidance-en-linea	687	4	2025-11-04 21:46:42.549921	2025-11-05 08:07:06.241886	\N	\N	f	\N	t	4	f
1092	https://www.r4.com/articulos-y-analisis/valores/acerinox-previo-1t25-a-la-espera-de-la-recuperacion-para-el-2t25	687	4	2025-11-04 21:46:43.708893	2025-11-05 08:07:07.463528	\N	\N	f	\N	t	4	f
1093	https://www.r4.com/articulos-y-analisis/valores/acerinox-preparados-para-el-futuro-del-sector-actualizacion-abril-2025	687	4	2025-11-04 21:46:44.858256	2025-11-05 08:07:08.688215	\N	\N	f	\N	t	4	f
1094	https://www.r4.com/articulos-y-analisis/valores/acerinox-2024-mejor-de-lo-esperado-en-terminos-ajustados-recuperacion-a-la-vista	687	4	2025-11-04 21:46:46.009299	2025-11-05 08:07:09.914992	\N	\N	f	\N	t	4	f
1095	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0132105018/2	687	4	2025-11-04 21:46:47.159296	2025-11-05 08:07:11.198425	\N	\N	f	\N	t	4	f
1096	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0178165017	688	4	2025-11-04 21:46:48.356741	2025-11-05 08:07:12.422602	\N	\N	f	\N	t	4	f
1097	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0112501012	689	4	2025-11-04 21:46:49.524276	2025-11-05 08:07:13.626737	\N	\N	f	\N	t	4	f
1099	https://www.r4.com/articulos-y-analisis/valores/tubacex-2t25-buenos-resultados-a-pesar-de-la-incertidumbre	690	4	2025-11-04 21:46:51.913948	2025-11-05 08:07:16.103922	\N	\N	f	\N	t	4	f
1100	https://www.r4.com/articulos-y-analisis/valores/tubacex-previo-2t25-se-empieza-a-notar-la-incertidumbre	690	4	2025-11-04 21:46:53.064253	2025-11-05 08:07:17.360659	\N	\N	f	\N	t	4	f
1101	https://www.r4.com/articulos-y-analisis/valores/tubacex-la-incertidumbre-empanara-ligeramente-el-positivo-2025-esperado	690	4	2025-11-04 21:46:54.221799	2025-11-05 08:07:18.566941	\N	\N	f	\N	t	4	f
1102	https://www.r4.com/articulos-y-analisis/valores/tubacex-1t25-record-trimestral-en-margenes-a-la-espera-de-la-aceleracion-en-el-2s25	690	4	2025-11-04 21:46:55.408728	2025-11-05 08:07:19.831648	\N	\N	f	\N	t	4	f
1103	https://www.r4.com/articulos-y-analisis/valores/tubacex-previo-1t25-ano-de-menos-a-mas	690	4	2025-11-04 21:46:56.567406	2025-11-05 08:07:21.06623	\N	\N	f	\N	t	4	f
1104	https://www.r4.com/articulos-y-analisis/valores/tubacex-salto-cuantitativo-y-cualitativo-en-2025	690	4	2025-11-04 21:46:57.717821	2025-11-05 08:07:22.263255	\N	\N	f	\N	t	4	f
1105	https://www.r4.com/articulos-y-analisis/valores/tubacex-cambio-de-consejero-delegado	690	4	2025-11-04 21:46:58.874791	2025-11-05 08:07:23.494489	\N	\N	f	\N	t	4	f
1106	https://www.r4.com/articulos-y-analisis/valores/tubacex-licencia-a-adnoc-el-derecho-de-uso-de-sentinel-prime	690	4	2025-11-04 21:47:00.023051	2025-11-05 08:07:24.745704	\N	\N	f	\N	t	4	f
1107	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0132945017/2	690	4	2025-11-04 21:47:01.172688	2025-11-05 08:07:25.961256	\N	\N	f	\N	t	4	f
1108	https://www.r4.com/articulos-y-analisis/valores/melia-previo-3t-25-otro-verano-record-en-espana-p-o-8-2-eur-antes-8-8-eur-sobreponderar	691	4	2025-11-04 21:47:02.355052	2025-11-05 08:07:27.182334	\N	\N	f	\N	t	4	f
1109	https://www.r4.com/articulos-y-analisis/valores/melia-entrevista-a-d-gabriel-escarrer-en-el-diario-expansion	691	4	2025-11-04 21:47:03.568565	2025-11-05 08:07:28.420681	\N	\N	f	\N	t	4	f
1111	https://www.r4.com/articulos-y-analisis/valores/melia-hoteles-previo-2t25-buen-tono-con-impulso-de-la-semana-santa	691	4	2025-11-04 21:47:05.925572	2025-11-05 08:07:30.948612	\N	\N	f	\N	t	4	f
1112	https://www.r4.com/articulos-y-analisis/valores/melia-hoteles-incumple-previsiones-se-mantiene-la-debilidad-en-cuba-buen-inicio-en-2t-con-una-semana-santa-positiva	691	4	2025-11-04 21:47:07.081656	2025-11-05 08:07:32.155655	\N	\N	f	\N	t	4	f
1113	https://www.r4.com/articulos-y-analisis/valores/melia-hoteles-previo-1t25-buen-tono-con-un-efecto-comparativo-exigente	691	4	2025-11-04 21:47:08.256425	2025-11-05 08:07:33.366695	\N	\N	f	\N	t	4	f
1114	https://www.r4.com/articulos-y-analisis/valores/melia-hoteles-resultados-4t-24-supera-ampliamente-las-previsiones-y-los-objetivos-de-la-guia-2024e-buen-inicio-previsto-en-2025e-un-ano-de-crecimiento-mas-moderado	691	4	2025-11-04 21:47:09.447533	2025-11-05 08:07:34.612692	\N	\N	f	\N	t	4	f
1115	https://www.r4.com/articulos-y-analisis/valores/melia-hoteles-previo-4t24-buen-final-de-ano-y-expectativas-moderadamente-optimistas-para-2025e	691	4	2025-11-04 21:47:10.669684	2025-11-05 08:07:35.867695	\N	\N	f	\N	t	4	f
1116	https://www.r4.com/articulos-y-analisis/valores/melia-entrevista-a-d-gabriel-escarrer-en-prensa	691	4	2025-11-04 21:47:11.812994	2025-11-05 08:07:37.045245	\N	\N	f	\N	t	4	f
1117	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0176252718/2	691	4	2025-11-04 21:47:12.965379	2025-11-05 08:07:39.333907	\N	\N	f	\N	t	4	f
1118	https://www.r4.com/articulos-y-analisis/valores/unicaja-2t25-fuerte-generacion-de-margen-de-intereses-mejoran-guias	692	4	2025-11-04 21:47:14.127233	2025-11-05 08:07:40.534907	\N	\N	f	\N	t	4	f
1119	https://www.r4.com/articulos-y-analisis/valores/sector-financiero-previo-resultados-2t25-margen-para-mejorar-guias	692	4	2025-11-04 21:47:15.288016	2025-11-05 08:07:41.758045	\N	\N	f	\N	t	4	f
1166	https://www.r4.com/articulos-y-analisis/cripto/mercados-en-movimiento	759	4	2025-11-04 21:48:22.218813	2025-11-05 08:08:40.661992	\N	\N	f	\N	t	4	f
1489	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-nvidia-lidera-la-vuelta-de-las-grandes-tecnologicas-en-medio-del-desplome-del-petroleo	1078	5	2025-11-04 21:57:05.76561	2025-11-05 08:18:24.08356	\N	\N	f	\N	t	4	f
1121	https://www.r4.com/articulos-y-analisis/valores/unicaja-1t25-solidos-resultados-en-la-buena-direccion-para-poder-mejorar-guias	692	4	2025-11-04 21:47:17.625833	2025-11-05 08:07:44.231129	\N	\N	f	\N	t	4	f
1122	https://www.r4.com/articulos-y-analisis/valores/sector-financiero-previo-1t25-se-mantienen-las-buenas-perspectivas	692	4	2025-11-04 21:47:18.781697	2025-11-05 08:07:45.535765	\N	\N	f	\N	t	4	f
1123	https://www.r4.com/articulos-y-analisis/valores/unicaja-plan-estrategico-2025-27-hora-de-ponerse-a-la-altura	692	4	2025-11-04 21:47:19.93816	2025-11-05 08:07:46.768146	\N	\N	f	\N	t	4	f
1124	https://www.r4.com/articulos-y-analisis/valores/unicaja-4t24-guias-2025-en-linea-con-entorno-de-bajadas-de-tipos	692	4	2025-11-04 21:47:21.124146	2025-11-05 08:07:47.942343	\N	\N	f	\N	t	4	f
1125	https://www.r4.com/articulos-y-analisis/valores/sector-financiero-previo-banco-4t24-sin-sorpresas-esperadas	692	4	2025-11-04 21:47:22.390139	2025-11-05 08:07:49.209158	\N	\N	f	\N	t	4	f
1126	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0180907000/2	692	4	2025-11-04 21:47:23.560052	2025-11-05 08:07:50.424449	\N	\N	f	\N	t	4	f
1127	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0140609019	693	4	2025-11-04 21:47:24.735976	2025-11-05 08:07:51.651331	\N	\N	f	\N	t	4	f
1128	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0113900J37	695	4	2025-11-04 21:47:25.907039	2025-11-05 08:07:52.840762	\N	\N	f	\N	t	4	f
1129	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0165386014	698	4	2025-11-04 21:47:27.126211	2025-11-05 08:07:54.058166	\N	\N	f	\N	t	4	f
1130	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0154653911	699	4	2025-11-04 21:47:28.322637	2025-11-05 08:07:55.246138	\N	\N	f	\N	t	4	f
1131	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0183746314	700	4	2025-11-04 21:47:29.490674	2025-11-05 08:07:56.449756	\N	\N	f	\N	t	4	f
1132	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0130625512	702	4	2025-11-04 21:47:30.659314	2025-11-05 08:07:57.648567	\N	\N	f	\N	t	4	f
1134	https://www.r4.com/articulos-y-analisis/valores/natac-1s25-mejora-del-guidance-en-terminos-de-margen	704	4	2025-11-04 21:47:33.011249	2025-11-05 08:08:00.108921	\N	\N	f	\N	t	4	f
1135	https://www.r4.com/articulos-y-analisis/valores/navigator-3t25-excelencia-operativa-e-integracion-vertical-para-capear-el-temporal	704	4	2025-11-04 21:47:34.165184	2025-11-05 08:08:01.354594	\N	\N	f	\N	t	4	f
1136	https://www.r4.com/articulos-y-analisis/valores/4	704	4	2025-11-04 21:47:36.242577	2025-11-05 08:08:02.552176	\N	\N	f	\N	t	4	f
1137	https://www.r4.com/serviciosr4/boletin-analisis-tecnico?soc=web:boletintecnico:texto	708	4	2025-11-04 21:47:38.376327	2025-11-05 08:08:03.763013	\N	\N	f	\N	t	4	f
1138	https://www.r4.com/articulos-y-analisis/valores/que-ha-hecho-el-dax-40-en-55-anos-despues-de-empezar-asi-el-ano	710	4	2025-11-04 21:47:39.514859	2025-11-05 08:08:05.002832	\N	\N	f	\N	t	4	f
1246	https://www.r4.com/inversion-para-todos/ahorra-en-casa	822	4	2025-11-04 21:50:33.683376	2025-11-05 08:10:49.454289	\N	\N	f	\N	t	4	f
1139	https://www.r4.com/articulos-y-analisis/valores/aunque-no-seais-tecnicos-mirad-esta-directriz-clave-para-el-medio-plazo-de-bbva	710	4	2025-11-04 21:47:41.618247	2025-11-05 08:08:06.198402	\N	\N	f	\N	t	4	f
1140	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0105223004	711	4	2025-11-04 21:47:43.889216	2025-11-05 08:08:07.382129	\N	\N	f	\N	t	4	f
1142	https://www.r4.com/articulos-y-analisis/tecnico/merlin-unibail-rodamco-y-covivio-rompen-y-consolidan-resistencias	722	4	2025-11-04 21:47:47.031531	2025-11-05 08:08:09.806473	\N	\N	f	\N	t	4	f
1143	https://www.r4.com/articulos-y-analisis/tecnico/un-punto-de-diversificacion-en-el-paladio-que-esta-rompiendo-importantes-niveles	722	4	2025-11-04 21:47:49.425416	2025-11-05 08:08:10.991326	\N	\N	f	\N	t	4	f
1144	https://www.r4.com/articulos-y-analisis/tecnico/niveles-clave-de-inversion-en-intuitive-surgical	722	4	2025-11-04 21:47:50.595192	2025-11-05 08:08:12.206018	\N	\N	f	\N	t	4	f
1145	https://www.r4.com/articulos-y-analisis/tecnico/momento-de-infraponderar-bancos-bbva-vs-ibex35	722	4	2025-11-04 21:47:52.701978	2025-11-05 08:08:13.44176	\N	\N	f	\N	t	4	f
1146	https://www.r4.com/articulos-y-analisis/tecnico/4t-historicamente-100-alcista-revive-el-sector-salud	722	4	2025-11-04 21:47:54.842313	2025-11-05 08:08:14.649359	\N	\N	f	\N	t	4	f
1147	https://www.r4.com/articulos-y-analisis/tecnico/akzo-nobel-fraguando-un-cambio-de-tendencia-desde-2020	722	4	2025-11-04 21:47:56.067452	2025-11-05 08:08:15.862585	\N	\N	f	\N	t	4	f
1148	https://www.r4.com/articulos-y-analisis/tecnico/despues-de-25-anos-el-eurostoxx-50-celebra-nuevos-maximos-historicos	722	4	2025-11-04 21:47:57.250441	2025-11-05 08:08:17.09541	\N	\N	f	\N	t	4	f
1149	https://www.r4.com/articulos-y-analisis/tecnico/4	722	4	2025-11-04 21:47:58.406942	2025-11-05 08:08:18.297362	\N	\N	f	\N	t	4	f
1150	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-megatendencias-salud-a-cierre-de-agosto-de-2025	748	4	2025-11-04 21:48:00.444632	2025-11-05 08:08:19.527014	\N	\N	f	\N	t	4	f
1151	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-pegasus-a-cierre-de-agosto-de-2025	748	4	2025-11-04 21:48:02.622822	2025-11-05 08:08:20.731645	\N	\N	f	\N	t	4	f
1152	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-megatendencias-tecnologia-a-cierre-de-agosto-de-2025	748	4	2025-11-04 21:48:03.782657	2025-11-05 08:08:21.930952	\N	\N	f	\N	t	4	f
1153	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-eeuu-acciones-fi-a-cierre-de-agosto-de-2025	748	4	2025-11-04 21:48:04.927226	2025-11-05 08:08:23.12383	\N	\N	f	\N	t	4	f
1154	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-europa-acciones-a-cierre-de-agosto-de-2025	748	4	2025-11-04 21:48:07.180376	2025-11-05 08:08:24.310951	\N	\N	f	\N	t	4	f
1155	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-bolsa-espana-a-cierre-de-agosto-de-2025	748	4	2025-11-04 21:48:09.385803	2025-11-05 08:08:25.528759	\N	\N	f	\N	t	4	f
1156	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-cripto-a-cierre-de-agosto-de-2025	748	4	2025-11-04 21:48:10.549592	2025-11-05 08:08:26.788164	\N	\N	f	\N	t	4	f
1158	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-megatendencias-medio-ambiente-a-cierre-de-agosto-de-2025	748	4	2025-11-04 21:48:12.859723	2025-11-05 08:08:29.236839	\N	\N	f	\N	t	4	f
1159	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-latinoamerica-a-cierre-de-agosto-de-2025	748	4	2025-11-04 21:48:14.022589	2025-11-05 08:08:30.461094	\N	\N	f	\N	t	4	f
1160	https://www.r4.com/articulos-y-analisis/fondos/4	748	4	2025-11-04 21:48:15.173554	2025-11-05 08:08:32.814675	\N	\N	f	\N	t	4	f
1161	https://www.r4.com/articulos-y-analisis/cripto/bitcoin-se-sacude-la-incertidumbre-y-lidera-el-rebote-de-los-mercados	759	4	2025-11-04 21:48:16.338875	2025-11-05 08:08:34.063919	\N	\N	f	\N	t	4	f
1162	https://www.r4.com/articulos-y-analisis/cripto/mientras-unos-minan-y-otros-legislan-bitcoin-consolida-su-trono	759	4	2025-11-04 21:48:17.519494	2025-11-05 08:08:35.2722	\N	\N	f	\N	t	4	f
1163	https://www.r4.com/articulos-y-analisis/cripto/semana-de-fuego-cruzado-economico-con-mercados-bajo-presion	759	4	2025-11-04 21:48:18.692537	2025-11-05 08:08:36.468181	\N	\N	f	\N	t	4	f
1164	https://www.r4.com/articulos-y-analisis/cripto/entiendes-realmente-como-funcionan-las-tarifas	759	4	2025-11-04 21:48:19.883095	2025-11-05 08:08:37.942533	\N	\N	f	\N	t	4	f
1165	https://www.r4.com/articulos-y-analisis/cripto/la-carrera-por-el-futuro-financiero	759	4	2025-11-04 21:48:21.034534	2025-11-05 08:08:39.484236	\N	\N	f	\N	t	4	f
1664	https://www.r4.com/articulos-y-analisis/tecnico/posicionamiento-de-los-clientes-de-goldman-sachs-gasolina-para-el-s-p500	1149	5	2025-11-04 22:02:13.082239	2025-11-05 08:23:24.889724	\N	\N	f	\N	t	4	f
1168	https://www.r4.com/articulos-y-analisis/cripto/volatilidad-reserva-cripto-trump	759	4	2025-11-04 21:48:24.539553	2025-11-05 08:08:43.112695	\N	\N	f	\N	t	4	f
1169	https://www.r4.com/articulos-y-analisis/cripto/hackeo-bybit	759	4	2025-11-04 21:48:25.697016	2025-11-05 08:08:44.307483	\N	\N	f	\N	t	4	f
1170	https://www.r4.com/articulos-y-analisis/cripto/bitcoin-solana-institucion-cripto	759	4	2025-11-04 21:48:26.853593	2025-11-05 08:08:45.546012	\N	\N	f	\N	t	4	f
1171	https://www.r4.com/articulos-y-analisis/cripto/4	759	4	2025-11-04 21:48:28.032328	2025-11-05 08:08:46.818811	\N	\N	f	\N	t	4	f
1172	https://www.r4.com/normativa/politica-privacidad/politica-privacidadclientes	760	4	2025-11-04 21:48:29.198832	2025-11-05 08:08:48.023386	\N	\N	f	\N	t	4	f
1175	https://www.r4.com/inversion-para-todos/trading-que-es-y-como-funciona	784	4	2025-11-04 21:48:33.431301	2025-11-05 08:08:51.861683	\N	\N	f	\N	t	4	f
1176	https://www.r4.com/inversion-para-todos/mejora-tu-planificacion-financiera-personal	785	4	2025-11-04 21:48:34.94298	2025-11-05 08:08:54.502492	\N	\N	f	\N	t	4	f
1177	https://www.r4.com/inversion-para-todos/que-son-los-derivados-financieros-y-sus-tipos	785	4	2025-11-04 21:48:36.539465	2025-11-05 08:08:56.043398	\N	\N	f	\N	t	4	f
1178	https://www.r4.com/inversion-para-todos/diferencias-entre-futuros-y-opciones-acierta-con-tu-eleccion	785	4	2025-11-04 21:48:38.030598	2025-11-05 08:08:58.19283	\N	\N	f	\N	t	4	f
1179	https://www.r4.com/inversion-para-todos/que-es-la-gestion-patrimonial-y-cuales-son-sus-ventajas	787	4	2025-11-04 21:48:39.572294	2025-11-05 08:08:59.730821	\N	\N	f	\N	t	4	f
1180	https://www.r4.com/inversion-para-todos/para-que-sirve-ahorrar	787	4	2025-11-04 21:48:41.004059	2025-11-05 08:09:01.210912	\N	\N	f	\N	t	4	f
1181	https://www.r4.com/inversion-para-todos/que-son-los-bonos-del-estado	787	4	2025-11-04 21:48:42.523148	2025-11-05 08:09:02.927029	\N	\N	f	\N	t	4	f
1182	https://www.r4.com/inversion-para-todos/metodo-50-30-20-ahorro	788	4	2025-11-04 21:48:44.004934	2025-11-05 08:09:04.396004	\N	\N	f	\N	t	4	f
1183	https://www.r4.com/inversion-para-todos/que-son-los-bonos-corporativos	789	4	2025-11-04 21:48:45.836415	2025-11-05 08:09:06.02416	\N	\N	f	\N	t	4	f
1184	https://www.r4.com/inversion-para-todos/que-es-renta-fija	789	4	2025-11-04 21:48:47.261723	2025-11-05 08:09:07.705312	\N	\N	f	\N	t	4	f
1185	https://www.r4.com/serviciosr4/asesoramiento-puntual	790	4	2025-11-04 21:48:48.901754	2025-11-05 08:09:09.380491	\N	\N	f	\N	t	4	f
1186	https://www.r4.com/inversion-para-todos/la-planificacion-financiera-en-cuatro-pasos	791	4	2025-11-04 21:48:50.098141	2025-11-05 08:09:10.563741	\N	\N	f	\N	t	4	f
1189	https://www.r4.com/inversion-para-todos/analisis-fundamental-vs-analisis-tecnico-formas-de-entender-la-inversion-que-se-complementan	794	4	2025-11-04 21:48:55.375999	2025-11-05 08:09:14.8138	\N	\N	f	\N	t	4	f
1193	https://www.r4.com/inversion-para-todos/tengo-un-plan-de-pensiones-puedo-cobrar-tambien-una-pension	797	4	2025-11-04 21:49:01.012624	2025-11-05 08:09:21.152866	\N	\N	f	\N	t	4	f
1194	https://www.r4.com/inversion-para-todos/erte-y-declaracion-de-la-renta	797	4	2025-11-04 21:49:02.836353	2025-11-05 08:09:22.614691	\N	\N	f	\N	t	4	f
1195	https://www.r4.com/inversion-para-todos/sp-500-que-es-como-funciona-y-como-afecta-a-la-inversion	798	4	2025-11-04 21:49:04.281476	2025-11-05 08:09:24.271053	\N	\N	f	\N	t	4	f
1196	https://www.r4.com/inversion-para-todos/que-es-la-pignoracion-de-participaciones-de-un-fondo	802	4	2025-11-04 21:49:05.756098	2025-11-05 08:09:25.853408	\N	\N	f	\N	t	4	f
1197	https://www.r4.com/inversion-para-todos/que-son-las-aportaciones-periodicas-a-fondos-de-inversion	802	4	2025-11-04 21:49:07.236599	2025-11-05 08:09:27.897143	\N	\N	f	\N	t	4	f
1198	https://www.r4.com/inversion-para-todos/como-complementar-la-pension-durante-la-jubilacion	802	4	2025-11-04 21:49:08.994975	2025-11-05 08:09:29.413221	\N	\N	f	\N	t	4	f
1199	https://www.r4.com/inversion-para-todos/finanzas-conductuales-que-son-y-como-usarlas-para-invertir-mejor	802	4	2025-11-04 21:49:10.910605	2025-11-05 08:09:31.046038	\N	\N	f	\N	t	4	f
1200	https://www.r4.com/inversion-para-todos/que-es-la-ratio-de-sharpe-y-que-mide	802	4	2025-11-04 21:49:12.980512	2025-11-05 08:09:32.696268	\N	\N	f	\N	t	4	f
1202	https://www.r4.com/inversion-para-todos/que-es-el-isin-de-un-fondo-de-inversion	802	4	2025-11-04 21:49:16.237281	2025-11-05 08:09:35.854607	\N	\N	f	\N	t	4	f
1203	https://www.r4.com/inversion-para-todos/que-son-las-mid-caps-son-una-buena-alternativa-para-invertir	802	4	2025-11-04 21:49:18.36536	2025-11-05 08:09:37.766499	\N	\N	f	\N	t	4	f
1204	https://www.r4.com/inversion-para-todos/diferencia-entre-forward-y-opciones	802	4	2025-11-04 21:49:20.194453	2025-11-05 08:09:39.489412	\N	\N	f	\N	t	4	f
1205	https://www.r4.com/inversion-para-todos/ebit-vs-ebitda-cual-es-la-diferencia	802	4	2025-11-04 21:49:21.657248	2025-11-05 08:09:40.997847	\N	\N	f	\N	t	4	f
1206	https://www.r4.com/inversion-para-todos/depositos-o-fondos-de-inversion-que-opcion-conviene-mas	802	4	2025-11-04 21:49:23.111394	2025-11-05 08:09:42.510941	\N	\N	f	\N	t	4	f
1207	https://www.r4.com/inversion-para-todos/que-es-el-domicilio-fiscal-y-como-se-determina	802	4	2025-11-04 21:49:25.195523	2025-11-05 08:09:43.984787	\N	\N	f	\N	t	4	f
1208	https://www.r4.com/inversion-para-todos/category/curiosidades-financieras/page/3	802	4	2025-11-04 21:49:26.746129	2025-11-05 08:09:45.944341	\N	\N	f	\N	t	4	f
1209	https://www.r4.com/inversion-para-todos/peliculas-economia	803	4	2025-11-04 21:49:28.434527	2025-11-05 08:09:47.963472	\N	\N	f	\N	t	4	f
1210	https://www.r4.com/inversion-para-todos/crack-del-29	803	4	2025-11-04 21:49:30.136287	2025-11-05 08:09:49.477792	\N	\N	f	\N	t	4	f
1211	https://www.r4.com/inversion-para-todos/toro-y-oso-en-la-bolsa	803	4	2025-11-04 21:49:32.187362	2025-11-05 08:09:52.042596	\N	\N	f	\N	t	4	f
1212	https://www.r4.com/inversion-para-todos/horarios-de-bolsa	803	4	2025-11-04 21:49:34.104406	2025-11-05 08:09:53.748211	\N	\N	f	\N	t	4	f
1213	https://www.r4.com/inversion-para-todos/tulipomania-primer-burbuja	803	4	2025-11-04 21:49:35.666052	2025-11-05 08:09:55.343283	\N	\N	f	\N	t	4	f
1214	https://www.r4.com/inversion-para-todos/category/curiosidades-financieras/page/5	803	4	2025-11-04 21:49:37.559171	2025-11-05 08:09:56.88557	\N	\N	f	\N	t	4	f
1215	https://www.r4.com/inversion-para-todos/recuperar-plan-de-pensiones	804	4	2025-11-04 21:49:39.060702	2025-11-05 08:09:58.73518	\N	\N	f	\N	t	4	f
1216	https://www.r4.com/inversion-para-todos/inversiones-de-bajo-riesgo	806	4	2025-11-04 21:49:40.505148	2025-11-05 08:10:00.324402	\N	\N	f	\N	t	4	f
1217	https://www.r4.com/inversion-para-todos/como-invertir-largo-plazo	806	4	2025-11-04 21:49:42.198566	2025-11-05 08:10:01.88143	\N	\N	f	\N	t	4	f
1219	https://www.r4.com/inversion-para-todos/conoces-los-bonos-verdes-te-contamos-para-que-se-utilizan	808	4	2025-11-04 21:49:46.403292	2025-11-05 08:10:04.934934	\N	\N	f	\N	t	4	f
1682	https://www.r4.com/articulos-y-analisis/cripto/podria-defi-beneficiarse-de-las-guerras-comerciales	1171	5	2025-11-04 22:02:46.137116	2025-11-05 08:23:47.37645	\N	\N	f	\N	t	4	f
1221	https://www.r4.com/inversion-para-todos/que-es-forex-como-funciona	811	4	2025-11-04 21:49:49.687457	2025-11-05 08:10:08.104399	\N	\N	f	\N	t	4	f
1222	https://www.r4.com/inversion-para-todos/que-es-la-gestion-discrecional-de-carteras	812	4	2025-11-04 21:49:52.336678	2025-11-05 08:10:09.815359	\N	\N	f	\N	t	4	f
1223	https://www.r4.com/articulos-y-analisis/ideas/gestion-activa-vs-pasiva-cual-es-la-mejor-estrategia-en-el-contexto-actual	812	4	2025-11-04 21:49:54.18674	2025-11-05 08:10:11.455756	\N	\N	f	\N	t	4	f
1225	https://www.r4.com/inversion-para-todos/que-son-socimis	818	4	2025-11-04 21:49:56.689619	2025-11-05 08:10:13.86182	\N	\N	f	\N	t	4	f
1226	https://www.r4.com/inversion-para-todos/dividendos-beneficio-indices	819	4	2025-11-04 21:49:58.276703	2025-11-05 08:10:15.402038	\N	\N	f	\N	t	4	f
1227	https://www.r4.com/inversion-para-todos/que-son-dividendos	819	4	2025-11-04 21:49:59.991681	2025-11-05 08:10:17.787904	\N	\N	f	\N	t	4	f
1228	https://www.r4.com/inversion-para-todos/cual-es-la-diferencia-entre-el-ipc-y-la-inflacion	820	4	2025-11-04 21:50:01.588317	2025-11-05 08:10:19.311377	\N	\N	f	\N	t	4	f
1229	https://www.r4.com/inversion-para-todos/cambio-fiscalidad-plan-pensiones	820	4	2025-11-04 21:50:03.092887	2025-11-05 08:10:20.83181	\N	\N	f	\N	t	4	f
1230	https://www.r4.com/inversion-para-todos/alternativas-inversion-jubilacion	820	4	2025-11-04 21:50:04.802134	2025-11-05 08:10:22.358179	\N	\N	f	\N	t	4	f
1231	https://www.r4.com/inversion-para-todos/quiz-educacion-financiera-2018	821	4	2025-11-04 21:50:06.343773	2025-11-05 08:10:24.040863	\N	\N	f	\N	t	4	f
1232	https://www.r4.com/inversion-para-todos/herramientas-inversion-verano	821	4	2025-11-04 21:50:08.029192	2025-11-05 08:10:25.99078	\N	\N	f	\N	t	4	f
1233	https://www.r4.com/inversion-para-todos/que-son-los-fondos-de-inversion-garantizados	821	4	2025-11-04 21:50:09.729656	2025-11-05 08:10:27.50525	\N	\N	f	\N	t	4	f
1234	https://www.r4.com/inversion-para-todos/como-funciona-el-mercado-de-derivados	821	4	2025-11-04 21:50:11.7257	2025-11-05 08:10:29.040067	\N	\N	f	\N	t	4	f
1235	https://www.r4.com/inversion-para-todos/invertir-en-deuda-autonomica-y-local	821	4	2025-11-04 21:50:13.774802	2025-11-05 08:10:30.548342	\N	\N	f	\N	t	4	f
1236	https://www.r4.com/inversion-para-todos/como-invertir-en-bonos-y-obligaciones-del-estado	821	4	2025-11-04 21:50:15.23221	2025-11-05 08:10:32.116436	\N	\N	f	\N	t	4	f
1237	https://www.r4.com/inversion-para-todos/fiscalidad-y-tributacion-de-las-letras-del-tesoro	821	4	2025-11-04 21:50:17.440541	2025-11-05 08:10:33.821609	\N	\N	f	\N	t	4	f
1238	https://www.r4.com/inversion-para-todos/que-es-la-comision-de-custodia-o-de-deposito	821	4	2025-11-04 21:50:19.510741	2025-11-05 08:10:35.337456	\N	\N	f	\N	t	4	f
1239	https://www.r4.com/inversion-para-todos/ahorrar-o-invertir-que-es-mejor-para-tus-finanzas	821	4	2025-11-04 21:50:21.334941	2025-11-05 08:10:37.311731	\N	\N	f	\N	t	4	f
1240	https://www.r4.com/inversion-para-todos/riesgos-renta-fija	821	4	2025-11-04 21:50:23.049737	2025-11-05 08:10:38.83788	\N	\N	f	\N	t	4	f
1241	https://www.r4.com/inversion-para-todos/como-se-reparte-una-herencia-en-espana	821	4	2025-11-04 21:50:25.026513	2025-11-05 08:10:40.382074	\N	\N	f	\N	t	4	f
1242	https://www.r4.com/inversion-para-todos/category/invertir-tus-ahorros/page/3	821	4	2025-11-04 21:50:26.820682	2025-11-05 08:10:41.933337	\N	\N	f	\N	t	4	f
1243	https://www.r4.com/inversion-para-todos/kakebo-ahorro	822	4	2025-11-04 21:50:28.450535	2025-11-05 08:10:43.953361	\N	\N	f	\N	t	4	f
1244	https://www.r4.com/inversion-para-todos/consejos-loteria	822	4	2025-11-04 21:50:29.977938	2025-11-05 08:10:46.266889	\N	\N	f	\N	t	4	f
1245	https://www.r4.com/inversion-para-todos/planes-pensiones-vs-depositos	822	4	2025-11-04 21:50:31.590575	2025-11-05 08:10:47.793045	\N	\N	f	\N	t	4	f
1247	https://www.r4.com/inversion-para-todos/la-jubilacion-para-los-autonomos	822	4	2025-11-04 21:50:35.690406	2025-11-05 08:10:52.120619	\N	\N	f	\N	t	4	f
1248	https://www.r4.com/inversion-para-todos/que-es-el-analisis-financiero	822	4	2025-11-04 21:50:38.038339	2025-11-05 08:10:53.698063	\N	\N	f	\N	t	4	f
1249	https://www.r4.com/inversion-para-todos/preguntas-respuestas-jubilacion	822	4	2025-11-04 21:50:39.907055	2025-11-05 08:10:55.171486	\N	\N	f	\N	t	4	f
1250	https://www.r4.com/inversion-para-todos/inversion-espana-ahorro	822	4	2025-11-04 21:50:41.643706	2025-11-05 08:10:56.757855	\N	\N	f	\N	t	4	f
1251	https://www.r4.com/inversion-para-todos/que-son-pensiones	822	4	2025-11-04 21:50:43.373423	2025-11-05 08:10:58.267634	\N	\N	f	\N	t	4	f
1252	https://www.r4.com/inversion-para-todos/ahorro-espanoles	822	4	2025-11-04 21:50:45.720556	2025-11-05 08:10:59.848571	\N	\N	f	\N	t	4	f
1254	https://www.r4.com/inversion-para-todos/category/invertir-tus-ahorros/page/6	822	4	2025-11-04 21:50:49.3436	2025-11-05 08:11:03.041758	\N	\N	f	\N	t	4	f
1255	https://www.r4.com/articulos-y-analisis/seguimiento-de-companias/guia-para-invertir-en-inteligencia-artificial	824	4	2025-11-04 21:50:52.205258	2025-11-05 08:11:05.169393	\N	\N	f	\N	t	4	f
1256	https://www.r4.com/serviciosr4/cursos-finanzas-gratis?soc=blogr4:cursos2022:texto	827	4	2025-11-04 21:50:54.214558	2025-11-05 08:11:06.390703	\N	\N	f	\N	t	4	f
1257	https://www.r4.com/serviciosr4/cursos-finanzas-gratis?soc=youtube:cursos2022:texto	827	4	2025-11-04 21:50:55.83489	2025-11-05 08:11:07.942313	\N	\N	f	\N	t	4	f
1258	https://www.r4.com/inversion-para-todos/desconecta-en-vacaciones	829	4	2025-11-04 21:50:57.469724	2025-11-05 08:11:09.51041	\N	\N	f	\N	t	4	f
1259	https://www.r4.com/inversion-para-todos/los-beneficios-de-la-tristeza	832	4	2025-11-04 21:50:59.243371	2025-11-05 08:11:11.08735	\N	\N	f	\N	t	4	f
1260	https://www.r4.com/inversion-para-todos/10-consejos-inversion-incertidumbre	837	4	2025-11-04 21:51:00.864223	2025-11-05 08:11:12.633976	\N	\N	f	\N	t	4	f
1262	https://www.r4.com/serviciosr4/expertos-en-inversion	838	4	2025-11-04 21:51:03.664564	2025-11-05 08:11:15.344214	\N	\N	f	\N	t	4	f
1263	https://www.r4.com/inversion-para-todos/consejos-ahorro-lista-compra	840	4	2025-11-04 21:51:05.218794	2025-11-05 08:11:16.847449	\N	\N	f	\N	t	4	f
1264	https://www.r4.com/inversion-para-todos/inversor-ahorro-periodico	841	4	2025-11-04 21:51:06.863039	2025-11-05 08:11:19.08653	\N	\N	f	\N	t	4	f
1265	https://www.r4.com/inversion-para-todos/velero-aldebaran	844	4	2025-11-04 21:51:08.418257	2025-11-05 08:11:20.625912	\N	\N	f	\N	t	4	f
1266	https://www.r4.com/inversion-para-todos/descubre-la-opera	844	4	2025-11-04 21:51:10.608278	2025-11-05 08:11:22.16195	\N	\N	f	\N	t	4	f
1268	https://www.r4.com/inversion-para-todos/que-es-la-escucha-activa	844	4	2025-11-04 21:51:14.272996	2025-11-05 08:11:25.324411	\N	\N	f	\N	t	4	f
1269	https://www.r4.com/inversion-para-todos/gestion-tiempo	844	4	2025-11-04 21:51:16.972719	2025-11-05 08:11:26.855337	\N	\N	f	\N	t	4	f
1270	https://www.r4.com/inversion-para-todos/salud-y-ahorro	844	4	2025-11-04 21:51:18.763766	2025-11-05 08:11:28.449695	\N	\N	f	\N	t	4	f
1271	https://www.r4.com/inversion-para-todos/proceso-creativo-literatura	844	4	2025-11-04 21:51:20.295483	2025-11-05 08:11:30.008381	\N	\N	f	\N	t	4	f
1272	https://www.r4.com/inversion-para-todos/reconciliacion-politica-sociedad	844	4	2025-11-04 21:51:21.844955	2025-11-05 08:11:31.589417	\N	\N	f	\N	t	4	f
1273	https://www.r4.com/inversion-para-todos/influencers-al-descubierto	844	4	2025-11-04 21:51:23.469993	2025-11-05 08:11:33.127429	\N	\N	f	\N	t	4	f
1699	https://www.r4.com/inversion-para-todos/origenes-jubilacion-y-pensiones	1198	5	2025-11-04 22:03:15.89682	2025-11-05 08:24:11.985129	\N	\N	f	\N	t	4	f
587	https://r4.com/que-necesitas/formacion	301	3	2025-11-04 21:34:00.412254	2025-11-05 07:54:20.696308	\N	\N	f	\N	t	4	f
1275	https://www.r4.com/inversion-para-todos/consigue-tus-metas	844	4	2025-11-04 21:51:27.270459	2025-11-05 08:11:36.465886	\N	\N	f	\N	t	4	f
1276	https://www.r4.com/inversion-para-todos/que-es-astenia-otonal	844	4	2025-11-04 21:51:28.829755	2025-11-05 08:11:38.553024	\N	\N	f	\N	t	4	f
1278	https://www.r4.com/inversion-para-todos/consejos-para-dormir	844	4	2025-11-04 21:51:31.938121	2025-11-05 08:11:41.871036	\N	\N	f	\N	t	4	f
1279	https://www.r4.com/inversion-para-todos/kaizen-pereza-1-minuto	844	4	2025-11-04 21:51:33.503736	2025-11-05 08:11:43.526515	\N	\N	f	\N	t	4	f
1280	https://www.r4.com/inversion-para-todos/organiza-tu-desorden	844	4	2025-11-04 21:51:35.711887	2025-11-05 08:11:45.514455	\N	\N	f	\N	t	4	f
1281	https://www.r4.com/inversion-para-todos/ahorra-tiempo	844	4	2025-11-04 21:51:38.036623	2025-11-05 08:11:47.140352	\N	\N	f	\N	t	4	f
1282	https://www.r4.com/inversion-para-todos/inversion-opcion-necesidad	849	4	2025-11-04 21:51:39.728456	2025-11-05 08:11:48.756022	\N	\N	f	\N	t	4	f
1283	ps://www.r4.com/inversion-para-todos/pasivos-financieros-que-son-tipos-y-ejemplos	852	4	2025-11-04 21:51:41.212603	2025-11-05 08:11:50.485783	\N	\N	f	\N	t	4	f
1284	https://www.r4.com/inversion-para-todos/resultados-empresariales-bolsa	855	4	2025-11-04 21:51:42.273165	2025-11-05 08:11:51.516703	\N	\N	f	\N	t	4	f
1285	https://www.r4.com/inversion-para-todos/empresas-unicornio	855	4	2025-11-04 21:51:43.997571	2025-11-05 08:11:54.035357	\N	\N	f	\N	t	4	f
1286	https://www.r4.com/inversion-para-todos/deuda-interna-y-principales-caracteristicas	856	4	2025-11-04 21:51:45.555438	2025-11-05 08:11:55.713248	\N	\N	f	\N	t	4	f
1287	https://www.r4.com/inversion-para-todos/que-son-megatendencias	862	4	2025-11-04 21:51:47.220658	2025-11-05 08:11:57.130235	\N	\N	f	\N	t	4	f
1289	https://www.r4.com/inversion-para-todos/que-es-economia-conductual	866	4	2025-11-04 21:51:51.783042	2025-11-05 08:12:00.162709	\N	\N	f	\N	t	4	f
1290	https://www.r4.com/inversion-para-todos/historia-dinero-divisas	869	4	2025-11-04 21:51:53.721852	2025-11-05 08:12:01.923117	\N	\N	f	\N	t	4	f
1291	https://www.r4.com/inversion-para-todos/que-es-el-tesoro-publico-y-para-que-sirve	872	4	2025-11-04 21:51:55.262848	2025-11-05 08:12:03.404265	\N	\N	f	\N	t	4	f
1292	https://www.r4.com/broker-online/productos-de-inversion/renta-fija/letras-del-tesoro/que-son-las-letras-del-tesoro	872	4	2025-11-04 21:51:57.198322	2025-11-05 08:12:05.084031	\N	\N	f	\N	t	4	f
1293	https://www.r4.com/articulos-y-analisis/ideas/oportunidad-de-inversion-en-oro	873	4	2025-11-04 21:51:58.724203	2025-11-05 08:12:06.302374	\N	\N	f	\N	t	4	f
1294	https://www.r4.com/autor/%20	876	4	2025-11-04 21:51:59.943253	2025-11-05 08:12:07.513697	\N	\N	f	\N	t	4	f
1295	https://www.r4.com/fondos-de-inversion/gama-de-fondos	876	4	2025-11-04 21:52:01.184487	2025-11-05 08:12:08.761444	\N	\N	f	\N	t	4	f
1296	https://www.r4.com/analisis-actualidad/noticias-gestora	876	4	2025-11-04 21:52:02.406175	2025-11-05 08:12:10.014284	\N	\N	f	\N	t	4	f
1297	https://www.r4.com/conferencias/evento-finfluencers/live-streaming	885	4	2025-11-04 21:52:03.673792	2025-11-05 08:12:11.334563	\N	\N	f	\N	t	4	f
1298	https://www.r4.com/articulos-y-analisis/noticias-renta4/fundacion-sonar-despierto-y-fundacion-renta-4-uniendo-fuerzas-por-el-futuro-de-jovenes-extutelados	886	4	2025-11-04 21:52:05.029498	2025-11-05 08:12:12.625499	\N	\N	f	\N	t	4	f
1300	https://www.r4.com/articulos-y-analisis/noticias-renta4/fundacion-renta-4-continua-su-colaboracion-con-la-ong-amor-sin-barreras-en-apoyo-a-comunidades-vulnerables-de-kenia	886	4	2025-11-04 21:52:09.514145	2025-11-05 08:12:14.966444	\N	\N	f	\N	t	4	f
1301	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-celebra-el-ii-encuentro-entre-inversores-y-empresas-cotizadas-en-la-bolsa-de-madrid	886	4	2025-11-04 21:52:11.727111	2025-11-05 08:12:16.140018	\N	\N	f	\N	t	4	f
1302	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-reafirma-su-compromiso-con-la-fundacion-prodis-en-su-25o-aniversario	886	4	2025-11-04 21:52:14.178371	2025-11-05 08:12:17.322738	\N	\N	f	\N	t	4	f
1303	https://www.r4.com/articulos-y-analisis/noticias-renta4/los-gestores-de-renta-4-gestora-analizan-las-oportunidades-en-un-contexto-de-alta-incertidumbre-en-la-vi-edicion-del-investor-s-day	886	4	2025-11-04 21:52:16.547757	2025-11-05 08:12:18.515847	\N	\N	f	\N	t	4	f
1304	https://www.r4.com/articulos-y-analisis/noticias-renta4/dia-mundial-del-sindrome-de-down-impulsando-la-inclusion-laboral	886	4	2025-11-04 21:52:18.897312	2025-11-05 08:12:19.709237	\N	\N	f	\N	t	4	f
1305	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-une-a-inversores-empresas-y-analistas-en-la-bolsa-de-madrid	886	4	2025-11-04 21:52:21.153912	2025-11-05 08:12:20.907135	\N	\N	f	\N	t	4	f
1306	https://www.r4.com/articulos-y-analisis/noticias-renta4/dia-internacional-de-las-ongs-el-compromiso-de-la-fundacion-renta-4	886	4	2025-11-04 21:52:23.638369	2025-11-05 08:12:22.073078	\N	\N	f	\N	t	4	f
1307	https://www.r4.com/articulos-y-analisis/noticias-renta4/nuevo-proyecto-de-la-ong-sendera-de-la-mano-de-la-fundacion-renta-4	886	4	2025-11-04 21:52:24.897441	2025-11-05 08:12:23.211184	\N	\N	f	\N	t	4	f
1308	https://www.r4.com/articulos-y-analisis/area-prensa/4	886	4	2025-11-04 21:52:27.241412	2025-11-05 08:12:25.309238	\N	\N	f	\N	t	4	f
1309	http://www.r4.com/fondos-de-inversion/tipos-de-fondos-de-inversion	891	4	2025-11-04 21:52:29.253696	2025-11-05 08:12:27.326957	\N	\N	f	\N	t	4	f
1310	http://www.r4.com/fondos-de-inversion/cuando-entrar-en-un-fondo-de-inversion	891	4	2025-11-04 21:52:30.443366	2025-11-05 08:12:28.543871	\N	\N	f	\N	t	4	f
1311	http://www.r4.com/fondos-de-inversion/fiscalidad-tributacion-fondos-de-inversion	891	4	2025-11-04 21:52:31.667616	2025-11-05 08:12:29.741811	\N	\N	f	\N	t	4	f
1312	http://www.r4.com/fondos-de-inversion/como-funciona-un-fondo-de-inversion	891	4	2025-11-04 21:52:32.906224	2025-11-05 08:12:30.992272	\N	\N	f	\N	t	4	f
1313	http://www.r4.com/fondos-de-inversion/los-mejores-fondos-de-inversion-como-identificarlos	891	4	2025-11-04 21:52:34.200225	2025-11-05 08:12:32.17402	\N	\N	f	\N	t	4	f
1314	http://www.r4.com/fondos-de-inversion/donde-contratar-fondos-de-inversion	891	4	2025-11-04 21:52:35.473016	2025-11-05 08:12:33.333045	\N	\N	f	\N	t	4	f
1315	http://www.r4.com/fondos-de-inversion/riesgos-de-los-fondos-de-inversion	891	4	2025-11-04 21:52:36.835359	2025-11-05 08:12:34.514858	\N	\N	f	\N	t	4	f
1316	http://www.r4.com/fondos-de-inversion/comisiones-fondos-de-inversion	891	4	2025-11-04 21:52:38.071656	2025-11-05 08:12:35.747579	\N	\N	f	\N	t	4	f
1317	http://www.r4.com/normativa/politica-privacidad	891	4	2025-11-04 21:52:39.388974	2025-11-05 08:12:36.926775	\N	\N	f	\N	t	4	f
1318	http://www.r4.com/broker-online/productos-de-inversion/bolsa/empezar-a-operar-en-bolsa	900	4	2025-11-04 21:52:40.532608	2025-11-05 08:12:38.16657	\N	\N	f	\N	t	4	f
1319	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0113860A34	904	5	2025-11-04 21:52:41.709231	2025-11-05 08:12:39.369797	\N	\N	f	\N	t	4	f
1320	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0113679I37	904	5	2025-11-04 21:52:43.914325	2025-11-05 08:12:40.539671	\N	\N	f	\N	t	4	f
1321	https://www.r4.com/articulos-y-analisis/valores/bbva-el-periodo-de-aceptacion-se-iniciara-en-septiembre	912	5	2025-11-04 21:52:46.05573	2025-11-05 08:12:41.724609	\N	\N	f	\N	t	4	f
1322	https://www.r4.com/articulos-y-analisis/valores/opa-sobre-sabadell-la-cnmc-da-luz-verde-a-la-operacion-ahora-turno-del-gobierno	912	5	2025-11-04 21:52:48.381913	2025-11-05 08:12:42.976513	\N	\N	f	\N	t	4	f
1493	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-microsoft-y-meta-versus-apple-y-amazon-fatiga-alcista-de-las-siete-magnificas	1084	5	2025-11-04 21:57:10.761463	2025-11-05 08:18:33.935653	\N	\N	f	\N	t	4	f
1324	https://www.r4.com/articulos-y-analisis/valores/bbva-1t25-buena-evolucion-operativa-pendientes-de-turquia	912	5	2025-11-04 21:52:53.101193	2025-11-05 08:12:45.376448	\N	\N	f	\N	t	4	f
1325	https://www.r4.com/articulos-y-analisis/valores/bbva-sin-catalizadores-a-corto-plazo-pendientes-de-la-opa-y-su-impacto	912	5	2025-11-04 21:52:54.370744	2025-11-05 08:12:46.543721	\N	\N	f	\N	t	4	f
1326	https://www.r4.com/articulos-y-analisis/valores/opa-sobre-sabadell-pocos-avances-seguimos-a-la-espera-de-la-cnmc	912	5	2025-11-04 21:52:56.581814	2025-11-05 08:12:47.732953	\N	\N	f	\N	t	4	f
1327	https://www.r4.com/articulos-y-analisis/valores/bbva-segundo-ajuste-de-la-ecuacion-de-canje-y-actualizacion-de-los-impactos-de-la-operacion	912	5	2025-11-04 21:52:58.836569	2025-11-05 08:12:48.865749	\N	\N	f	\N	t	4	f
1328	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0113211835	912	5	2025-11-04 21:53:01.156566	2025-11-05 08:12:50.051137	\N	\N	f	\N	t	4	f
1329	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0113211835/3	912	5	2025-11-04 21:53:03.326957	2025-11-05 08:12:51.292886	\N	\N	f	\N	t	4	f
1331	https://www.r4.com/articulos-y-analisis/valores/enagas-catalizadores-a-c-p-crecimiento-a-1-p-por-el-negocio-del-hidrogeno	922	5	2025-11-04 21:53:06.922241	2025-11-05 08:12:53.655088	\N	\N	f	\N	t	4	f
1332	https://www.r4.com/articulos-y-analisis/valores/enagas-9m24-en-la-senda-para-superar-objetivo	922	5	2025-11-04 21:53:08.110627	2025-11-05 08:12:54.834935	\N	\N	f	\N	t	4	f
1333	https://www.r4.com/articulos-y-analisis/valores/enagas-previo-9m24-sin-cambios-previstos-en-guia-2024-deuda-neta-recogera-positivamente-la-venta-de-tallgrass	922	5	2025-11-04 21:53:10.37409	2025-11-05 08:12:55.984553	\N	\N	f	\N	t	4	f
1334	https://www.r4.com/articulos-y-analisis/valores/conclusiones-enagas-1s24-no-descartan-recortar-dividendo-mas-alla-de-2026	922	5	2025-11-04 21:53:12.697643	2025-11-05 08:12:57.230699	\N	\N	f	\N	t	4	f
1335	https://www.r4.com/articulos-y-analisis/valores/enagas-1s24-sorpresa-positiva-en-ebitda-veremos-si-hay-cambios-en-los-objetivos-2024	922	5	2025-11-04 21:53:14.847278	2025-11-05 08:12:59.546584	\N	\N	f	\N	t	4	f
1336	https://www.r4.com/articulos-y-analisis/valores/enagas-ajustamos-p-o-tras-venta-de-tallgrass-incluimos-previo-cifras-1s24	922	5	2025-11-04 21:53:17.188008	2025-11-05 08:13:00.734565	\N	\N	f	\N	t	4	f
1337	https://www.r4.com/articulos-y-analisis/valores/enagas-1t24-en-linea-para-alcanzar-objetivos-2024-esperando-la-actualizacion-estrategica	922	5	2025-11-04 21:53:18.475167	2025-11-05 08:13:01.938812	\N	\N	f	\N	t	4	f
1338	https://www.r4.com/articulos-y-analisis/valores/enagas-restructurar-para-un-futuro-de-crecimiento	922	5	2025-11-04 21:53:20.754268	2025-11-05 08:13:03.075864	\N	\N	f	\N	t	4	f
1339	https://www.r4.com/articulos-y-analisis/valores/conclusiones-enagas-2023-recorte-significativo-de-los-dividendos-objetivos-2024-por-encima-de-previsiones	922	5	2025-11-04 21:53:23.206315	2025-11-05 08:13:05.483021	\N	\N	f	\N	t	4	f
1340	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0130960018	922	5	2025-11-04 21:53:25.764643	2025-11-05 08:13:07.642412	\N	\N	f	\N	t	4	f
1341	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0130960018/3	922	5	2025-11-04 21:53:27.314683	2025-11-05 08:13:09.801118	\N	\N	f	\N	t	4	f
1342	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0116870314	923	5	2025-11-04 21:53:29.558887	2025-11-05 08:13:10.982387	\N	\N	f	\N	t	4	f
1343	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0173093024	925	5	2025-11-04 21:53:31.683957	2025-11-05 08:13:12.208289	\N	\N	f	\N	t	4	f
1344	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0125220311	928	5	2025-11-04 21:53:33.969578	2025-11-05 08:13:14.329551	\N	\N	f	\N	t	4	f
1345	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0144580Y14	928	5	2025-11-04 21:53:35.267365	2025-11-05 08:13:16.347259	\N	\N	f	\N	t	4	f
1346	https://www.r4.com/articulos-y-analisis/valores/endesa-mas-redes-menos-renovables	935	5	2025-11-04 21:53:37.252788	2025-11-05 08:13:17.48434	\N	\N	f	\N	t	4	f
1347	https://www.r4.com/articulos-y-analisis/valores/endesa-mas-redes-menos-renovables-elevamos-p-o-y-recomendacion	935	5	2025-11-04 21:53:39.398605	2025-11-05 08:13:18.628966	\N	\N	f	\N	t	4	f
4237	http://www.r4.com/content/rentabanco/r4/es.html	1769	6	2025-11-05 08:35:26.923228	\N	\N	\N	f	\N	t	4	f
1348	https://www.r4.com/articulos-y-analisis/valores/endesa-acuerdo-para-la-compra-activos-hidraulicos-de-acciona	935	5	2025-11-04 21:53:41.845766	2025-11-05 08:13:20.95015	\N	\N	f	\N	t	4	f
1349	https://www.r4.com/articulos-y-analisis/valores/endesa-9m24-por-encima-de-las-expectativas	935	5	2025-11-04 21:53:43.052879	2025-11-05 08:13:23.12772	\N	\N	f	\N	t	4	f
1351	https://www.r4.com/articulos-y-analisis/valores/endesa-acuerdo-para-la-venta-de-una-participacion-minoritaria-en-activos-fotovoltaicos	935	5	2025-11-04 21:53:45.516856	2025-11-05 08:13:26.439757	\N	\N	f	\N	t	4	f
1352	https://www.r4.com/articulos-y-analisis/valores/endesa-1s24-buena-evolucion-de-la-caja-en-2t	935	5	2025-11-04 21:53:46.779675	2025-11-05 08:13:28.830884	\N	\N	f	\N	t	4	f
1353	https://www.r4.com/articulos-y-analisis/valores/endesa-1t24-resultado-neto-por-debajo-de-previsiones	935	5	2025-11-04 21:53:49.11335	2025-11-05 08:13:31.186565	\N	\N	f	\N	t	4	f
1354	https://www.r4.com/articulos-y-analisis/valores/endesa-2023-cifras-por-debajo-de-previsiones-y-objetivos-reiteran-guias-2024-2026	935	5	2025-11-04 21:53:50.339777	2025-11-05 08:13:33.54265	\N	\N	f	\N	t	4	f
1355	https://www.r4.com/articulos-y-analisis/valores/previo-endesa-2023-prevision-de-situarse-por-debajo-de-objetivos	935	5	2025-11-04 21:53:52.798616	2025-11-05 08:13:34.937358	\N	\N	f	\N	t	4	f
1356	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0130670112	935	5	2025-11-04 21:53:55.018455	2025-11-05 08:13:37.332741	\N	\N	f	\N	t	4	f
1357	https://www.r4.com/articulos-y-analisis/valores/ferrovial-previo-2024-operativa-y-venta-de-heathrow-marcaran-las-cifras-anuales	945	5	2025-11-04 21:53:57.090048	2025-11-05 08:13:39.382169	\N	\N	f	\N	t	4	f
1358	https://www.r4.com/articulos-y-analisis/valores/ferrovial-adjudicacion-proyectos-del-tren-de-alta-velocidad-britanico	945	5	2025-11-04 21:53:58.308127	2025-11-05 08:13:41.880626	\N	\N	f	\N	t	4	f
1359	https://www.r4.com/articulos-y-analisis/valores/ferrovial-9m24-p-l-alineado-con-nuestras-expectativas-deuda-neta-ligeramente-mejor	945	5	2025-11-04 21:54:00.479603	2025-11-05 08:13:44.247335	\N	\N	f	\N	t	4	f
1360	https://www.r4.com/articulos-y-analisis/valores/ferrovial-previo-9m24-estimamos-que-continue-el-crecimiento-en-el-p-l	945	5	2025-11-04 21:54:01.719941	2025-11-05 08:13:46.48485	\N	\N	f	\N	t	4	f
1361	https://www.r4.com/articulos-y-analisis/valores/ferrovial-se-abre-la-posibilidad-de-una-expropiacion-de-la-407	945	5	2025-11-04 21:54:02.952737	2025-11-05 08:13:48.949322	\N	\N	f	\N	t	4	f
1362	https://www.r4.com/articulos-y-analisis/valores/ferrovial-1s24-mejora-de-los-margenes-en-construccion-lleva-a-superar-previsiones-deterioro-de-la-caja-neta-superior-a-lo-esperado	945	5	2025-11-04 21:54:04.173138	2025-11-05 08:13:51.203713	\N	\N	f	\N	t	4	f
1363	https://www.r4.com/articulos-y-analisis/valores/ferrovial-previo-1s24-esperando-que-continue-la-fortaleza-de-las-managed-lanes	945	5	2025-11-04 21:54:05.369859	2025-11-05 08:13:53.658983	\N	\N	f	\N	t	4	f
1364	https://www.r4.com/articulos-y-analisis/valores/ferrovial-1t24-ebitda-mejora-notablemente-las-expectativas-caja-neta-se-deteriora-por-recompra-de-acciones-e-inversiones	945	5	2025-11-04 21:54:06.598739	2025-11-05 08:13:55.898869	\N	\N	f	\N	t	4	f
1365	https://www.r4.com/articulos-y-analisis/valores/ferrovial-compra-del-24-de-irb-infraestructure-trust	945	5	2025-11-04 21:54:07.803507	2025-11-05 08:13:58.074744	\N	\N	f	\N	t	4	f
1518	https://www.r4.com/articulos-y-analisis/valores/acerinox-preparados-para-el-futuro-del-sector	1095	5	2025-11-04 21:57:55.029768	2025-11-05 08:19:18.759601	\N	\N	f	\N	t	4	f
4183	https://www.r4.com/portal?TX=goto&FWD=AHORROPLAN	1691	6	2025-11-05 08:34:01.183283	\N	\N	\N	f	\N	t	4	f
1367	https://www.r4.com/articulos-y-analisis/valores/MCO+NL0015001FS8	945	5	2025-11-04 21:54:10.301768	2025-11-05 08:14:02.647636	\N	\N	f	\N	t	4	f
1368	https://www.r4.com/articulos-y-analisis/valores/MCO+NL0015001FS8/3	945	5	2025-11-04 21:54:11.49723	2025-11-05 08:14:04.768928	\N	\N	f	\N	t	4	f
1369	https://www.r4.com/articulos-y-analisis/valores/inditex-lanzara-su-canal-zara-streaming-el-25-de-septiembre	955	5	2025-11-04 21:54:12.952276	2025-11-05 08:14:06.85451	\N	\N	f	\N	t	4	f
1371	https://www.r4.com/articulos-y-analisis/valores/inditex-previo-2t-24-crecimiento-mas-moderado-en-linea-con-el-de-los-ultimos-trimestres-p-o-49-7-eur-mantener	955	5	2025-11-04 21:54:15.855818	2025-11-05 08:14:11.365477	\N	\N	f	\N	t	4	f
1372	https://www.r4.com/articulos-y-analisis/valores/inditex-con-margen-para-atacar-nuevos-maximos-p-o-49-7-eur-mantener	955	5	2025-11-04 21:54:17.106048	2025-11-05 08:14:13.581638	\N	\N	f	\N	t	4	f
1373	https://www.r4.com/articulos-y-analisis/valores/inditex-resultados-1t-24-en-linea-a-nivel-operativo-buen-inicio-en-2t-24-y-sin-novedades-en-cuanto-a-la-guia-p-o-y-recomendacion-en-revision-antes-39-5-eur-y-mantener	955	5	2025-11-04 21:54:18.33522	2025-11-05 08:14:15.830243	\N	\N	f	\N	t	4	f
1374	https://www.r4.com/articulos-y-analisis/valores/inditex-se-mantiene-la-linea-de-los-ultimos-trimestres-p-o-y-recomendacion-en-revision-antes-39-5-eur-y-mantener	955	5	2025-11-04 21:54:19.571951	2025-11-05 08:14:18.114401	\N	\N	f	\N	t	4	f
1375	https://www.r4.com/articulos-y-analisis/valores/inditex-resultados-4t-23-en-linea-vs-consenso-buen-inicio-en-1t-y-dividendo-2024e-en-linea-con-nuestra-prevision-y-mas-elevado-vs-consenso-p-o-39-5-eur-mantener	955	5	2025-11-04 21:54:20.88338	2025-11-05 08:14:19.337503	\N	\N	f	\N	t	4	f
1376	https://www.r4.com/articulos-y-analisis/valores/inditex-previo-4t-23-buena-evolucion-afectada-nuevamente-por-el-impacto-divisa-optimismo-moderado-de-cara-a-2024-p-o-39-5-eur-mantener	955	5	2025-11-04 21:54:22.110004	2025-11-05 08:14:21.464343	\N	\N	f	\N	t	4	f
1377	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0148396007	955	5	2025-11-04 21:54:23.334412	2025-11-05 08:14:23.749538	\N	\N	f	\N	t	4	f
1378	https://www.r4.com/articulos-y-analisis/valores/rovi-moderna-reduce-sus-previsiones-impactando-la-cotizacion	964	5	2025-11-04 21:54:24.571187	2025-11-05 08:14:25.062264	\N	\N	f	\N	t	4	f
1379	https://www.r4.com/articulos-y-analisis/valores/rovi-mantendra-el-100-de-su-filial-industrial-cdmo	964	5	2025-11-04 21:54:25.810746	2025-11-05 08:14:27.439218	\N	\N	f	\N	t	4	f
1380	https://www.r4.com/articulos-y-analisis/valores/rovi-2t24-destacada-recuperacion-de-resultados	964	5	2025-11-04 21:54:27.041258	2025-11-05 08:14:29.654959	\N	\N	f	\N	t	4	f
1381	https://www.r4.com/articulos-y-analisis/valores/rovi-pre-2t24-arranca-la-produccion-de-vacunas-y-con-ella-la-recuperacion-del-margen-bruto	964	5	2025-11-04 21:54:28.228765	2025-11-05 08:14:31.918351	\N	\N	f	\N	t	4	f
1382	https://www.r4.com/articulos-y-analisis/valores/rovi-1t24-los-menores-ingresos-de-fabricacion-reducen-los-resultados	964	5	2025-11-04 21:54:29.428383	2025-11-05 08:14:34.29993	\N	\N	f	\N	t	4	f
1383	https://www.r4.com/articulos-y-analisis/valores/rovi-pre-1t24-una-exigente-comparativa-y-la-menor-fabricacion-de-vacunas-pesan-en-los-resultados	964	5	2025-11-04 21:54:30.663226	2025-11-05 08:14:36.514794	\N	\N	f	\N	t	4	f
1384	https://www.r4.com/articulos-y-analisis/valores/rovi-cierra-un-acuerdo-para-la-fabricacion-de-jeringas-precargadas	964	5	2025-11-04 21:54:33.058134	2025-11-05 08:14:37.695918	\N	\N	f	\N	t	4	f
1385	https://www.r4.com/articulos-y-analisis/valores/rovi-la-fda-da-su-aprobacion-para-la-comercializacion-de-risvan-risperidona-ism-en-ee-uu	964	5	2025-11-04 21:54:34.305568	2025-11-05 08:14:38.896771	\N	\N	f	\N	t	4	f
1386	https://www.r4.com/articulos-y-analisis/valores/rovi-4t23-unas-expectativas-conservadoras-no-convencen-al-mercado-a-pesar-de-superar-las-expectativas-de-este-una-vez-mas	964	5	2025-11-04 21:54:35.615152	2025-11-05 08:14:41.225625	\N	\N	f	\N	t	4	f
1387	https://www.r4.com/articulos-y-analisis/valores/rovi-pre-4t23-una-comparativa-imposible-con-respecto-al-4t22	964	5	2025-11-04 21:54:37.778278	2025-11-05 08:14:43.489376	\N	\N	f	\N	t	4	f
1388	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0157261019	964	5	2025-11-04 21:54:38.993683	2025-11-05 08:14:45.8648	\N	\N	f	\N	t	4	f
1389	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0109427734	965	5	2025-11-04 21:54:40.168854	2025-11-05 08:14:47.922727	\N	\N	f	\N	t	4	f
1390	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0105130001	966	5	2025-11-04 21:54:42.230285	2025-11-05 08:14:50.043634	\N	\N	f	\N	t	4	f
1391	https://www.r4.com/articulos-y-analisis/valores/sacyr-separacion-funciones-ceo-y-presidente	983	5	2025-11-04 21:54:43.450202	2025-11-05 08:14:52.187289	\N	\N	f	\N	t	4	f
1392	https://www.r4.com/articulos-y-analisis/valores/sacyr-adjudicacion-de-concesion-en-chile	983	5	2025-11-04 21:54:44.698866	2025-11-05 08:14:54.442846	\N	\N	f	\N	t	4	f
1393	https://www.r4.com/articulos-y-analisis/valores/sacyr-9m24-gran-fortaleza-de-la-caja-operativa	983	5	2025-11-04 21:54:47.036451	2025-11-05 08:14:55.66994	\N	\N	f	\N	t	4	f
1394	https://www.r4.com/articulos-y-analisis/valores/previo-sacyr-9m24-pendientes-de-visibilidad-respecto-a-los-distintos-procesos-de-rotacion	983	5	2025-11-04 21:54:48.232055	2025-11-05 08:14:56.840542	\N	\N	f	\N	t	4	f
1395	https://www.r4.com/articulos-y-analisis/valores/previo-sacyr-1s24-esperamos-que-se-cumpla-con-la-evolucion-que-se-previo-en-el-cmd	983	5	2025-11-04 21:54:50.454827	2025-11-05 08:14:57.987535	\N	\N	f	\N	t	4	f
1396	https://www.r4.com/articulos-y-analisis/valores/sacyr-ha-llevado-a-cabo-una-colocacion-acelerada-del-9-6-del-capital-social	983	5	2025-11-04 21:54:51.688718	2025-11-05 08:14:59.131665	\N	\N	f	\N	t	4	f
1398	https://www.r4.com/articulos-y-analisis/valores/sacyr-1t24-los-margenes-mejoran-por-encima-de-la-expectativa	983	5	2025-11-04 21:54:54.209126	2025-11-05 08:15:03.557948	\N	\N	f	\N	t	4	f
1399	https://www.r4.com/articulos-y-analisis/valores/sacyr-nueva-concesion-en-italia	983	5	2025-11-04 21:54:55.457952	2025-11-05 08:15:05.83247	\N	\N	f	\N	t	4	f
1400	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0182870214	983	5	2025-11-04 21:54:56.712118	2025-11-05 08:15:08.154276	\N	\N	f	\N	t	4	f
1401	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0182870214/3	983	5	2025-11-04 21:54:57.944272	2025-11-05 08:15:10.278898	\N	\N	f	\N	t	4	f
1402	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-4t24-superan-ampliamente-la-prevision-de-ebitda-de-consenso-comentarios-con-tono-positivo-de-cara-a-2025e	991	5	2025-11-04 21:54:59.165198	2025-11-05 08:15:12.35534	\N	\N	f	\N	t	4	f
1403	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-estabilidad-en-4t-24-que-confirmaria-un-2s-24-en-la-parte-baja-del-ciclo-a-la-espera-de-una-recuperacion-de-los-precios	991	5	2025-11-04 21:55:00.384843	2025-11-05 08:15:13.551016	\N	\N	f	\N	t	4	f
1404	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-potencial-pendiente-de-que-mejore-el-entorno-operativo	991	5	2025-11-04 21:55:01.630152	2025-11-05 08:15:15.944062	\N	\N	f	\N	t	4	f
1405	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-3t24-condiciones-de-mercado-propias-de-la-parte-baja-del-ciclo-primeros-signos-de-recuperacion-p-o-30-7-eur-sobreponderar	991	5	2025-11-04 21:55:02.914159	2025-11-05 08:15:18.335889	\N	\N	f	\N	t	4	f
1445	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/mar-de-liquidez	1027	5	2025-11-04 21:56:10.866127	2025-11-05 08:16:38.711598	\N	\N	f	\N	t	4	f
1529	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-dia-del-inversor-no-se-vayan-todavia-aun-hay-mas-el-nuevo-guidance-supera-las-mejores-previsiones	1096	5	2025-11-04 21:58:13.191402	2025-11-05 08:19:46.10178	\N	\N	f	\N	t	4	f
1408	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-atractivo-a-la-espera-de-que-mejore-el-entorno-operativo-p-o-30-7-eur-antes-35-6-eur-sobreponderar	991	5	2025-11-04 21:55:06.692658	2025-11-05 08:15:22.914633	\N	\N	f	\N	t	4	f
1409	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-2t24-condiciones-de-mercado-propias-de-la-parte-baja-del-ciclo-catalizadores-identificados-y-cotizacion-en-niveles-atractivos-p-o-en-revision-antes-35-6-eur-sobreponderar	991	5	2025-11-04 21:55:07.921455	2025-11-05 08:15:24.087798	\N	\N	f	\N	t	4	f
1410	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-resultados-2t24-los-resultados-superan-previsiones-a-nivel-operativo-sin-cambios-en-la-guia-p-o-35-6-eur-sobreponderar	991	5	2025-11-04 21:55:09.064801	2025-11-05 08:15:25.266666	\N	\N	f	\N	t	4	f
1411	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-previo-2t-24-deterioro-previsto-en-2t-24-sin-perspectivas-de-gran-mejoria-en-2s-24-p-o-35-6-eur-y-sobreponderar	991	5	2025-11-04 21:55:10.277629	2025-11-05 08:15:26.459726	\N	\N	f	\N	t	4	f
1412	https://www.r4.com/articulos-y-analisis/valores/MCO+LU1598757687	991	5	2025-11-04 21:55:11.477647	2025-11-05 08:15:27.608927	\N	\N	f	\N	t	4	f
1413	https://www.r4.com/articulos-y-analisis/valores/MCO+LU1598757687/3	991	5	2025-11-04 21:55:13.402296	2025-11-05 08:15:29.566706	\N	\N	f	\N	t	4	f
1414	https://www.r4.com/articulos-y-analisis/valores/almirall-alcanza-un-acuerdo-de-licencia-de-la-molecula-zkn-013-dirigida-a-patologias-raras-de-la-piel	1003	5	2025-11-04 21:55:15.552161	2025-11-05 08:15:31.714477	\N	\N	f	\N	t	4	f
1415	https://www.r4.com/articulos-y-analisis/valores/almirall-4t23-nuevos-deterioros-le-devuelven-a-las-perdidas-en-2024-deberia-iniciar-la-mejora	1003	5	2025-11-04 21:55:17.994933	2025-11-05 08:15:32.913414	\N	\N	f	\N	t	4	f
1416	https://www.r4.com/articulos-y-analisis/valores/almirall-adquiere-la-licencia-del-anticuerpo-il-21-de-novo-nordisk-como-tratamiento-dermatologico	1003	5	2025-11-04 21:55:20.257618	2025-11-05 08:15:35.279173	\N	\N	f	\N	t	4	f
1417	https://www.r4.com/articulos-y-analisis/valores/almirall-pre-4t23-cumple-objetivos-en-un-ejercicio-de-transicion	1003	5	2025-11-04 21:55:22.503569	2025-11-05 08:15:37.673626	\N	\N	f	\N	t	4	f
1418	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0157097017	1003	5	2025-11-04 21:55:23.755908	2025-11-05 08:15:40.030106	\N	\N	f	\N	t	4	f
1419	https://www.r4.com/articulos-y-analisis/valores/iag-resultado-operativo-3t-24-supera-ampliamente-recorta-capacidad-y-la-prevision-de-gasto-en-combustible-2024e-anuncia-un-plan-de-recompra-p-o-3-08-eur-sobreponderar	1013	5	2025-11-04 21:55:25.03029	2025-11-05 08:15:42.241306	\N	\N	f	\N	t	4	f
1420	https://www.r4.com/articulos-y-analisis/valores/iag-previo-3t-24-datos-de-trafico-manteniendo-un-crecimiento-elevado-prevision-de-precios-mas-estables-la-situacion-geopolitica-principal-riesgo	1013	5	2025-11-04 21:55:27.324254	2025-11-05 08:15:43.40179	\N	\N	f	\N	t	4	f
1421	https://www.r4.com/articulos-y-analisis/valores/iag-ganando-altura-p-o-3-08-eur-antes-2-53-eur-sobreponderar	1013	5	2025-11-04 21:55:29.564686	2025-11-05 08:15:44.544772	\N	\N	f	\N	t	4	f
1422	https://www.r4.com/articulos-y-analisis/valores/iag-conferencia-2t-24-se-espera-que-la-fortaleza-de-la-demanda-continue-buenas-perspectivas-de-crecimiento-organico-en-madrid-p-o-2-53-eur-sobreponderar	1013	5	2025-11-04 21:55:31.924234	2025-11-05 08:15:46.83552	\N	\N	f	\N	t	4	f
1423	https://www.r4.com/articulos-y-analisis/valores/iag-los-resultados-2t24-superan-ampliamente-la-prevision-del-consenso-y-mayor-reduccion-de-deuda-de-lo-previsto	1013	5	2025-11-04 21:55:34.214932	2025-11-05 08:15:49.163208	\N	\N	f	\N	t	4	f
1424	https://www.r4.com/articulos-y-analisis/valores/iag-la-demanda-sigue-siendo-solida-con-prevision-de-precios-mas-estables-la-situacion-geopolitica-principal-riesgo-p-o-2-53-eur-sobreponderar	1013	5	2025-11-04 21:55:35.456541	2025-11-05 08:15:50.360282	\N	\N	f	\N	t	4	f
1425	https://www.r4.com/articulos-y-analisis/valores/iag-s-p-mejora-la-perspectiva-de-la-deuda	1013	5	2025-11-04 21:55:36.699099	2025-11-05 08:15:51.558529	\N	\N	f	\N	t	4	f
1426	https://www.r4.com/articulos-y-analisis/valores/iag-iberia-propone-aumentar-las-cesiones-de-rutas-de-air-europa	1013	5	2025-11-04 21:55:38.953514	2025-11-05 08:15:53.838195	\N	\N	f	\N	t	4	f
1427	https://www.r4.com/articulos-y-analisis/valores/iag-previo-1t-24-se-consolida-la-recuperacion-el-riesgo-geopolitico-principal-riesgo-p-o-2-53-eur-sobreponderar	1013	5	2025-11-04 21:55:40.243361	2025-11-05 08:15:56.111012	\N	\N	f	\N	t	4	f
1428	https://www.r4.com/articulos-y-analisis/valores/iag-los-resultados-superan-en-ingresos-y-en-linea-a-nivel-operativo-mejor-evolucion-de-la-deuda-neta-buen-inicio-de-cara-a-1s-24-p-o-2-53-eur-sobreponderar	1013	5	2025-11-04 21:55:42.675915	2025-11-05 08:15:59.418665	\N	\N	f	\N	t	4	f
1429	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0177542018	1013	5	2025-11-04 21:55:43.915136	2025-11-05 08:16:00.576273	\N	\N	f	\N	t	4	f
1430	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0177542018/3	1013	5	2025-11-04 21:55:46.03064	2025-11-05 08:16:02.690273	\N	\N	f	\N	t	4	f
1431	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0139140174	1022	5	2025-11-04 21:55:48.021479	2025-11-05 08:16:04.681972	\N	\N	f	\N	t	4	f
1432	https://www.r4.com/articulos-y-analisis/valores/merlin-properties-estima-un-impacto-del-8-5-en-ffo-ante-una-potencial-eliminacion-del-regimen-fiscal-de-las-socimi	1023	5	2025-11-04 21:55:49.313993	2025-11-05 08:16:06.874475	\N	\N	f	\N	t	4	f
1433	https://www.r4.com/articulos-y-analisis/valores/merlin-properties-3t24-9m24-importante-contratacion-y-positiva-sorpresa-por-mayor-ffo	1023	5	2025-11-04 21:55:50.547826	2025-11-05 08:16:09.241897	\N	\N	f	\N	t	4	f
1434	https://www.r4.com/articulos-y-analisis/valores/merlin-properties-previo-3t24-operativa-vs-normativa	1023	5	2025-11-04 21:55:51.823782	2025-11-05 08:16:11.472105	\N	\N	f	\N	t	4	f
1435	https://www.r4.com/articulos-y-analisis/valores/merlin-properties-2t24-1s24-valoracion-estable-y-mayor-flujo-de-caja-del-esperado	1023	5	2025-11-04 21:55:53.087068	2025-11-05 08:16:12.631871	\N	\N	f	\N	t	4	f
1436	https://www.r4.com/articulos-y-analisis/valores/socimis-dato-mata-relato	1023	5	2025-11-04 21:55:55.284187	2025-11-05 08:16:14.889464	\N	\N	f	\N	t	4	f
1437	https://www.r4.com/articulos-y-analisis/valores/merlin-properties-1t24-trimestre-sin-sorpresas-con-ffo-en-linea	1023	5	2025-11-04 21:55:56.515222	2025-11-05 08:16:17.277771	\N	\N	f	\N	t	4	f
1438	https://www.r4.com/articulos-y-analisis/valores/merlin-properties-previo-1t24-trimestre-sin-sorpresas	1023	5	2025-11-04 21:55:57.750763	2025-11-05 08:16:21.578925	\N	\N	f	\N	t	4	f
1440	https://www.r4.com/articulos-y-analisis/valores/merlin-properties-podria-vender-entre-50-000-y-100-000-metros-cuadrados-de-activos-de-oficinas	1023	5	2025-11-04 21:56:02.181094	2025-11-05 08:16:26.222695	\N	\N	f	\N	t	4	f
1441	https://www.r4.com/articulos-y-analisis/valores/merlin-properties-el-tribunal-supremo-da-el-respaldo-definitivo-a-madrid-nuevo-norte	1023	5	2025-11-04 21:56:03.409381	2025-11-05 08:16:28.445536	\N	\N	f	\N	t	4	f
1442	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105025003	1023	5	2025-11-04 21:56:05.629305	2025-11-05 08:16:30.831262	\N	\N	f	\N	t	4	f
1443	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105025003/3	1023	5	2025-11-04 21:56:07.639817	2025-11-05 08:16:33.053874	\N	\N	f	\N	t	4	f
1444	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0105122024	1026	5	2025-11-04 21:56:09.659972	2025-11-05 08:16:36.008514	\N	\N	f	\N	t	4	f
1454	https://www.r4.com/articulos-y-analisis/valores/telefonica-acuerdo-para-la-venta-de-telefonica-ecuador	1043	5	2025-11-04 21:56:22.25434	2025-11-05 08:17:01.315511	\N	\N	f	\N	t	4	f
1455	https://www.r4.com/articulos-y-analisis/valores/telefonica-segun-prensa-ha-contratado-a-az-capital-para-comprar-vodafone-espana	1043	5	2025-11-04 21:56:23.480701	2025-11-05 08:17:03.694821	\N	\N	f	\N	t	4	f
1456	https://www.r4.com/articulos-y-analisis/valores/telefonica-acuerdo-para-la-venta-de-telefonica-uruguay	1043	5	2025-11-04 21:56:24.733179	2025-11-05 08:17:06.248459	\N	\N	f	\N	t	4	f
1457	https://www.r4.com/articulos-y-analisis/valores/telefonica-tendencia-operativa-favorable-en-los-3-principales-mercados-consolidados	1043	5	2025-11-04 21:56:25.9788	2025-11-05 08:17:08.645297	\N	\N	f	\N	t	4	f
1459	https://www.r4.com/articulos-y-analisis/valores/telefonica-anuncia-un-acuerdo-para-crear-una-compania-de-servicios-para-empresas-en-reino-unido	1043	5	2025-11-04 21:56:28.422274	2025-11-05 08:17:13.924344	\N	\N	f	\N	t	4	f
1460	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0178430E18	1043	5	2025-11-04 21:56:29.696309	2025-11-05 08:17:16.395378	\N	\N	f	\N	t	4	f
1461	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0178430E18/3	1043	5	2025-11-04 21:56:30.948619	2025-11-05 08:17:18.784177	\N	\N	f	\N	t	4	f
1462	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-el-triple-efecto-powell	1048	5	2025-11-04 21:56:32.221391	2025-11-05 08:17:21.290262	\N	\N	f	\N	t	4	f
4174	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-megatendencias-consumo-a-cierre-de-julio-de-2025	1680	6	2025-11-05 08:33:45.526171	\N	\N	\N	f	\N	t	4	f
1447	https://r4.com/que-necesitas/contacto	1031	5	2025-11-04 21:56:13.302948	2025-11-05 08:16:44.780805	\N	\N	f	\N	t	4	f
1448	https://www.r4.com/servicios-gestion/planificacion-financiera?int=propia:plfinanciera:bannerint	1035	5	2025-11-04 21:56:14.672491	2025-11-05 08:16:46.402705	\N	\N	f	\N	t	4	f
1450	https://www.r4.com/articulos-y-analisis/valores/telefonica-tendencia-operativa-favorable-en-espana-y-brasil-y-debilidad-en-reino-unido-buenas-oportunidades-de-crecimiento-en-tecnologia	1043	5	2025-11-04 21:56:17.159759	2025-11-05 08:16:50.762506	\N	\N	f	\N	t	4	f
1451	https://www.r4.com/articulos-y-analisis/valores/telefonica-cumplen-a-nivel-operativo-deuda-neta-en-linea-y-caida-adicional-prevista-encaminada-para-cumplir-con-los-objetivos-2025e	1043	5	2025-11-04 21:56:18.443317	2025-11-05 08:16:53.122458	\N	\N	f	\N	t	4	f
1452	https://www.r4.com/articulos-y-analisis/valores/telefonica-cambio-de-perimetro-en-hispam-con-la-venta-de-filiales-y-depreciacion-de-divisas-latam	1043	5	2025-11-04 21:56:19.713407	2025-11-05 08:16:56.017528	\N	\N	f	\N	t	4	f
1453	https://www.r4.com/articulos-y-analisis/valores/telefonica-vmo2-uk-compra-espectro-en-reino-unido	1043	5	2025-11-04 21:56:21.006464	2025-11-05 08:16:58.440271	\N	\N	f	\N	t	4	f
1463	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-walmart-enciende-de-nuevo-los-espiritus-animales	1048	5	2025-11-04 21:56:33.449091	2025-11-05 08:17:23.736332	\N	\N	f	\N	t	4	f
1464	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-el-yen-trade-y-el-nikkei-mas-alla-del-banco-de-japon	1048	5	2025-11-04 21:56:34.69075	2025-11-05 08:17:26.121517	\N	\N	f	\N	t	4	f
1465	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-que-le-pasa-a-la-banca-europea	1048	5	2025-11-04 21:56:35.958055	2025-11-05 08:17:28.641765	\N	\N	f	\N	t	4	f
1466	https://www.r4.com/fondos-de-inversion/seleccion50/LU1923622291	1060	5	2025-11-04 21:56:37.202995	2025-11-05 08:17:31.127827	\N	\N	f	\N	t	4	f
1467	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=ES0173394034&DIVI=EUR&CBR=	1061	5	2025-11-04 21:56:38.512397	2025-11-05 08:17:33.073124	\N	\N	f	\N	t	4	f
1468	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=DK0062498333&MKT=MFR	1068	5	2025-11-04 21:56:39.688429	2025-11-05 08:17:34.235214	\N	\N	f	\N	t	4	f
1469	https://www.r4.com/articulos-y-analisis/ideas/inditex-entra-en-nuestras-carteras-versatil-y-5-grandes	1071	5	2025-11-04 21:56:40.859418	2025-11-05 08:17:35.393392	\N	\N	f	\N	t	4	f
1470	https://www.r4.com/articulos-y-analisis/ideas/multigestora-etfs-para-el-entorno-actual	1071	5	2025-11-04 21:56:42.080762	2025-11-05 08:17:37.664703	\N	\N	f	\N	t	4	f
1471	https://www.r4.com/articulos-y-analisis/ideas/cambio-cartera-divideno-versatil	1071	5	2025-11-04 21:56:43.255176	2025-11-05 08:17:40.052458	\N	\N	f	\N	t	4	f
1472	https://www.r4.com/articulos-y-analisis/ideas/que-son-unit-linked	1071	5	2025-11-04 21:56:44.508747	2025-11-05 08:17:42.572064	\N	\N	f	\N	t	4	f
1473	https://www.r4.com/articulos-y-analisis/ideas/nuevos-fondos-renta-variable-seleccion-50-1S25	1071	5	2025-11-04 21:56:45.745689	2025-11-05 08:17:44.930163	\N	\N	f	\N	t	4	f
1474	https://www.r4.com/articulos-y-analisis/ideas/por-que-el-riesgo-divisa-importa	1071	5	2025-11-04 21:56:46.970541	2025-11-05 08:17:47.495951	\N	\N	f	\N	t	4	f
1475	https://www.r4.com/articulos-y-analisis/ideas/se-acerca-un-cambio-de-guardia-en-la-bolsa-europea	1071	5	2025-11-04 21:56:48.18827	2025-11-05 08:17:49.061067	\N	\N	f	\N	t	4	f
1476	https://www.r4.com/articulos-y-analisis/ideas/tecnicas-reunidas-reemplaza-a-tubaces-en-la-cartera-versatil	1071	5	2025-11-04 21:56:49.545101	2025-11-05 08:17:51.488988	\N	\N	f	\N	t	4	f
1477	https://www.r4.com/articulos-y-analisis/ideas/nuevos-fondos-de-renta-fija-para-la-seleccion-50	1071	5	2025-11-04 21:56:50.894348	2025-11-05 08:17:54.169795	\N	\N	f	\N	t	4	f
1478	https://www.r4.com/articulos-y-analisis/ideas/5	1071	5	2025-11-04 21:56:52.123942	2025-11-05 08:17:56.742289	\N	\N	f	\N	t	4	f
1479	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/lo-que-no-encaja-en-el-rally-de-agosto-y-por-que-todo-gira-en-torno-a-la-crypto-expansion-monetaria	1075	5	2025-11-04 21:56:53.31215	2025-11-05 08:17:59.103017	\N	\N	f	\N	t	4	f
1480	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/trump-inicia-su-gran-experimento-con-jubilo-de-las-bolsas-y-avances-en-el-proyecto-cripto-de-liquidez-total	1075	5	2025-11-04 21:56:54.564433	2025-11-05 08:18:01.558413	\N	\N	f	\N	t	4	f
1481	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/como-descontarian-las-bolsas-un-escenario-de-estanflacion-suave	1075	5	2025-11-04 21:56:55.789336	2025-11-05 08:18:04.008309	\N	\N	f	\N	t	4	f
1482	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/las-bolsas-se-rinden-a-trump	1075	5	2025-11-04 21:56:57.02652	2025-11-05 08:18:06.333364	\N	\N	f	\N	t	4	f
1483	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/los-resultados-los-datos-macro-y-la-ley-genius-neutralizan-el-temor-a-trump	1075	5	2025-11-04 21:56:58.254313	2025-11-05 08:18:09.123267	\N	\N	f	\N	t	4	f
1484	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-s-p-pone-rumbo-a-los-7-000-puntos-mientras-vuelven-los-aranceles	1075	5	2025-11-04 21:56:59.493169	2025-11-05 08:18:11.812248	\N	\N	f	\N	t	4	f
1486	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/realidad-y-ficcion-se-confunden-en-las-bolsas-de-trump	1075	5	2025-11-04 21:57:01.994944	2025-11-05 08:18:16.881174	\N	\N	f	\N	t	4	f
1487	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/bolsas-y-bancos-centrales-en-compas-de-espera	1075	5	2025-11-04 21:57:03.22503	2025-11-05 08:18:19.396858	\N	\N	f	\N	t	4	f
1488	https://www.r4.com/columnas-de-autores/vive-la-pasion-de-los-mercados/3	1075	5	2025-11-04 21:57:04.480929	2025-11-05 08:18:21.930892	\N	\N	f	\N	t	4	f
1532	https://www.r4.com/articulos-y-analisis/valores/tre-contrato-feed-convertible-en-arabia-saudi	1096	5	2025-11-04 21:58:16.88858	2025-11-05 08:19:53.432725	\N	\N	f	\N	t	4	f
1706	https://www.r4.com/inversion-para-todos/la-teoria-del-pintalabios-rojo	1208	5	2025-11-04 22:03:27.995114	2025-11-05 08:24:23.387332	\N	\N	f	\N	t	4	f
1953	https://www.r4.com/articulos-y-analisis/valores/puig-brands-avance-ventas-9m24-la-reaceleracion-en-el-crecimiento-permite-reiterar-guia-pese-a-las-dificultades-en-apac	1506	6	2025-11-04 22:10:50.744935	2025-11-05 08:30:26.047491	\N	\N	f	\N	t	4	f
4184	https://www.r4.com/inversion-para-todos/metodos-de-ahorro-en-invierno	1696	6	2025-11-05 08:34:02.698561	\N	\N	\N	f	\N	t	4	f
1490	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-walmart-y-dow-jones-un-nuevo-episodio-de-main-street-frente-a-wall-street	1082	5	2025-11-04 21:57:07.034077	2025-11-05 08:18:26.384657	\N	\N	f	\N	t	4	f
1491	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-el-hilo-conductor-entre-el-ibex-y-el-vix	1084	5	2025-11-04 21:57:08.269413	2025-11-05 08:18:28.965064	\N	\N	f	\N	t	4	f
1492	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-la-curiosa-conexion-entre-el-ethereum-y-apple	1084	5	2025-11-04 21:57:09.484718	2025-11-05 08:18:31.520051	\N	\N	f	\N	t	4	f
1494	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/acuerdo-comercial-para-la-galeria-de-imposible-cumplimiento	1084	5	2025-11-04 21:57:11.996784	2025-11-05 08:18:35.742875	\N	\N	f	\N	t	4	f
1495	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-el-nikkei-celebra-el-acuerdo-comercial	1084	5	2025-11-04 21:57:13.194681	2025-11-05 08:18:37.176981	\N	\N	f	\N	t	4	f
1496	https://www.r4.com/articulos-y-analisis/mercados/5	1084	5	2025-11-04 21:57:14.468561	2025-11-05 08:18:39.529134	\N	\N	f	\N	t	4	f
1497	https://www.r4.com/articulos-y-analisis/valores/puig-brands-previo-avance-ventas-3t25-aun-cumpliendo-guia-atencion-al-sell-in-pre-navidad	1085	5	2025-11-04 21:57:15.713783	2025-11-05 08:18:41.870871	\N	\N	f	\N	t	4	f
1498	https://www.r4.com/articulos-y-analisis/valores/puig-brands-la-familia-puig-recompra-el-0-24-del-capital	1085	5	2025-11-04 21:57:16.908209	2025-11-05 08:18:43.370839	\N	\N	f	\N	t	4	f
1499	https://www.r4.com/articulos-y-analisis/valores/puig-brands-1s25-el-apalancamiento-operativo-y-mejoras-de-eficiencia-mas-que-compensan-el-mayor-gasto-en-publicidad	1085	5	2025-11-04 21:57:18.113906	2025-11-05 08:18:44.885642	\N	\N	f	\N	t	4	f
1500	https://www.r4.com/articulos-y-analisis/valores/puig-brands-previo-1s25-esperamos-normalizacion-en-crecimiento-y-leve-expansion-de-margenes	1085	5	2025-11-04 21:57:19.349856	2025-11-05 08:18:46.118985	\N	\N	f	\N	t	4	f
1501	https://www.r4.com/articulos-y-analisis/valores/puig-brands-avance-ventas-2t25-reiteran-guia-para-2s25-antes-de-un-incierto-2026	1085	5	2025-11-04 21:57:20.622861	2025-11-05 08:18:47.35102	\N	\N	f	\N	t	4	f
1502	https://www.r4.com/articulos-y-analisis/valores/puig-brands-previo-avance-ventas-2t25-cumpliendo-guia-pese-al-complejo-entorno-de-ciclo-aranceles-y-divisas	1085	5	2025-11-04 21:57:21.885583	2025-11-05 08:18:48.607727	\N	\N	f	\N	t	4	f
1503	https://www.r4.com/articulos-y-analisis/valores/puig-brands-avance-ventas-1t25-continua-superando-las-cifras-del-sector	1085	5	2025-11-04 21:57:24.328396	2025-11-05 08:18:50.901483	\N	\N	f	\N	t	4	f
1504	https://www.r4.com/articulos-y-analisis/valores/puig-brands-avance-ventas-1t25-optimistas-antes-de-la-tormenta	1085	5	2025-11-04 21:57:26.68724	2025-11-05 08:18:53.185658	\N	\N	f	\N	t	4	f
1505	https://www.r4.com/articulos-y-analisis/valores/puig-brands-2s24-2024-mejorando-estimaciones-de-ebitda-aj-y-generacion-de-caja-optimistas-para-2025	1085	5	2025-11-04 21:57:29.05885	2025-11-05 08:18:55.381762	\N	\N	f	\N	t	4	f
1506	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105777017/2	1085	5	2025-11-04 21:57:31.5278	2025-11-05 08:18:56.585652	\N	\N	f	\N	t	4	f
1507	https://www.r4.com/articulos-y-analisis/valores/repsol-previo-3t25-esperamos-resultados-apoyados-por-los-margenes-de-refino-aunque-el-entorno-continua-siendo-desafiante	1086	5	2025-11-04 21:57:33.789587	2025-11-05 08:18:58.700393	\N	\N	f	\N	t	4	f
1508	https://www.r4.com/articulos-y-analisis/valores/repsol-inicia-la-produccion-de-gasolina-100-renovable	1086	5	2025-11-04 21:57:36.201347	2025-11-05 08:19:00.951633	\N	\N	f	\N	t	4	f
1509	https://www.r4.com/articulos-y-analisis/valores/repsol-trading-statement-del-3t2025	1086	5	2025-11-04 21:57:38.579066	2025-11-05 08:19:02.149901	\N	\N	f	\N	t	4	f
1510	https://www.r4.com/articulos-y-analisis/valores/repsol-primer-petroleo-en-leon-castile	1086	5	2025-11-04 21:57:40.945208	2025-11-05 08:19:04.423305	\N	\N	f	\N	t	4	f
1511	https://www.r4.com/articulos-y-analisis/valores/repsol-2t25-empezando-a-recoger-los-frutos-del-trabajo-bien-hecho-reiteran-guias-para-2025	1086	5	2025-11-04 21:57:43.194058	2025-11-05 08:19:06.752945	\N	\N	f	\N	t	4	f
1512	https://www.r4.com/articulos-y-analisis/valores/repsol-2t25-superando-al-consenso-y-cumpliendo-compromisos	1086	5	2025-11-04 21:57:45.579156	2025-11-05 08:19:09.102965	\N	\N	f	\N	t	4	f
1513	https://www.r4.com/articulos-y-analisis/valores/repsol-previo-2t25-cumpliendo-compromisos-pese-a-las-dificultades	1086	5	2025-11-04 21:57:46.849343	2025-11-05 08:19:10.375502	\N	\N	f	\N	t	4	f
1514	https://www.r4.com/articulos-y-analisis/valores/repsol-adquisicion-comercializadora-edf	1086	5	2025-11-04 21:57:48.06183	2025-11-05 08:19:11.568772	\N	\N	f	\N	t	4	f
1515	https://www.r4.com/articulos-y-analisis/valores/repsol-trading-statement-del-2t2025	1086	5	2025-11-04 21:57:49.328342	2025-11-05 08:19:12.816654	\N	\N	f	\N	t	4	f
1516	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0173516115/2	1086	5	2025-11-04 21:57:51.601644	2025-11-05 08:19:14.045461	\N	\N	f	\N	t	4	f
1517	https://www.r4.com/articulos-y-analisis/valores/acerinox-previo-2024-continua-la-debilidad	1095	5	2025-11-04 21:57:53.763998	2025-11-05 08:19:16.40439	\N	\N	f	\N	t	4	f
1519	https://www.r4.com/articulos-y-analisis/valores/acerinox-3t24-la-debilidad-del-sector-situa-los-resultados-por-debajo-de-lo-esperado	1095	5	2025-11-04 21:57:57.307307	2025-11-05 08:19:21.593776	\N	\N	f	\N	t	4	f
1520	https://www.r4.com/articulos-y-analisis/valores/acerinox-previo-3t24-continua-la-debilidad	1095	5	2025-11-04 21:57:58.522001	2025-11-05 08:19:23.95191	\N	\N	f	\N	t	4	f
1521	https://www.r4.com/articulos-y-analisis/valores/acerinox-venta-de-bahru	1095	5	2025-11-04 21:58:00.773826	2025-11-05 08:19:26.368754	\N	\N	f	\N	t	4	f
1522	https://www.r4.com/articulos-y-analisis/valores/acerinox-2t24-mejor-en-margenes-y-deuda-ligeramente-peor-en-guidance	1095	5	2025-11-04 21:58:01.921199	2025-11-05 08:19:28.76041	\N	\N	f	\N	t	4	f
1523	https://www.r4.com/articulos-y-analisis/valores/acerinox-previo-2t24-recuperacion-mas-lenta-de-lo-esperado	1095	5	2025-11-04 21:58:04.280274	2025-11-05 08:19:31.222081	\N	\N	f	\N	t	4	f
1524	https://www.r4.com/articulos-y-analisis/valores/acx-cambios-estrategicos-relevantes	1095	5	2025-11-04 21:58:05.560399	2025-11-05 08:19:33.780163	\N	\N	f	\N	t	4	f
1525	https://www.r4.com/articulos-y-analisis/valores/acerinox-1t24-nas-y-vdm-continuan-siendo-los-motores-con-europa-que-sigue-sin-mejorar	1095	5	2025-11-04 21:58:06.810382	2025-11-05 08:19:36.64897	\N	\N	f	\N	t	4	f
1526	https://www.r4.com/articulos-y-analisis/valores/acerinox-previo-1t24-ano-de-menos-a-mas	1095	5	2025-11-04 21:58:08.0221	2025-11-05 08:19:39.03395	\N	\N	f	\N	t	4	f
1527	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0132105018	1095	5	2025-11-04 21:58:09.229107	2025-11-05 08:19:41.563277	\N	\N	f	\N	t	4	f
1528	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0132105018/3	1095	5	2025-11-04 21:58:11.174936	2025-11-05 08:19:43.966506	\N	\N	f	\N	t	4	f
1530	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-2-de-octubre-la-siguiente-fase-del-plan-estrategico-salta	1096	5	2025-11-04 21:58:14.444606	2025-11-05 08:19:48.633978	\N	\N	f	\N	t	4	f
1531	https://www.r4.com/articulos-y-analisis/valores/tre-2t25-record-trimestral-de-ebitda-alcanzado-el-4-5-de-margen-en-el-2t	1096	5	2025-11-04 21:58:15.656278	2025-11-05 08:19:51.018495	\N	\N	f	\N	t	4	f
1972	https://www.r4.com/articulos-y-analisis/valores/acx-inversiones-en-vdm-y-nuevo-plan-de-excelencia	1528	6	2025-11-04 22:11:22.467908	2025-11-05 08:30:51.173803	\N	\N	f	\N	t	4	f
4175	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-europa-acciones-a-cierre-de-julio-de-2025	1680	6	2025-11-05 08:33:46.751703	\N	\N	\N	f	\N	t	4	f
1533	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-previo-2t25-no-descartamos-sorpresas-positivas	1096	5	2025-11-04 21:58:19.139899	2025-11-05 08:19:55.850711	\N	\N	f	\N	t	4	f
1534	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-no-se-vayan-todavia-aun-hay-mas	1096	5	2025-11-04 21:58:20.419097	2025-11-05 08:19:58.494731	\N	\N	f	\N	t	4	f
1536	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-previo-1t25-normalizacion-del-margen-ebit-al-4	1096	5	2025-11-04 21:58:22.990609	2025-11-05 08:20:03.891837	\N	\N	f	\N	t	4	f
1537	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-a-confirmar-el-plan-estrategico-en-2025	1096	5	2025-11-04 21:58:24.20712	2025-11-05 08:20:06.477688	\N	\N	f	\N	t	4	f
1538	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0178165017/2	1096	5	2025-11-04 21:58:25.475981	2025-11-05 08:20:07.688292	\N	\N	f	\N	t	4	f
1539	https://www.r4.com/articulos-y-analisis/valores/ebro-foods-previo-9m25-solidos-resultados-con-el-foco-en-los-precios-de-las-materias-primas	1097	5	2025-11-04 21:58:27.551209	2025-11-05 08:20:08.909859	\N	\N	f	\N	t	4	f
1540	https://www.r4.com/articulos-y-analisis/valores/ebro-foods-1s25-record-semestral-de-ebitda-en-un-primer-semestre-con-un-dificil-entorno	1097	5	2025-11-04 21:58:29.795243	2025-11-05 08:20:11.395879	\N	\N	f	\N	t	4	f
1541	https://www.r4.com/articulos-y-analisis/valores/ebro-foods-previo-1s25-normalizando-los-buenos-resultados	1097	5	2025-11-04 21:58:32.034492	2025-11-05 08:20:12.592117	\N	\N	f	\N	t	4	f
1542	https://www.r4.com/articulos-y-analisis/valores/ebro-foods-1t25-en-linea-con-lo-esperado	1097	5	2025-11-04 21:58:33.239302	2025-11-05 08:20:13.733805	\N	\N	f	\N	t	4	f
1543	https://www.r4.com/articulos-y-analisis/valores/ebro-foods-previo-1t25-mejorando-lo-dificilmente-mejorable	1097	5	2025-11-04 21:58:34.43542	2025-11-05 08:20:17.260644	\N	\N	f	\N	t	4	f
1544	https://www.r4.com/articulos-y-analisis/valores/ebro-foods-crecimiento-sostenible-ignorado-por-el-mercado	1097	5	2025-11-04 21:58:36.74543	2025-11-05 08:20:19.654258	\N	\N	f	\N	t	4	f
1545	https://www.r4.com/articulos-y-analisis/valores/ebro-foods-2024-nuevo-record-de-resultados-que-baten-al-guidance	1097	5	2025-11-04 21:58:38.900298	2025-11-05 08:20:22.01388	\N	\N	f	\N	t	4	f
1546	https://www.r4.com/articulos-y-analisis/valores/ebro-foods-previo-2024-un-ano-mas-batiendo-records	1097	5	2025-11-04 21:58:40.095252	2025-11-05 08:20:23.149964	\N	\N	f	\N	t	4	f
1547	https://www.r4.com/articulos-y-analisis/valores/ebro-foods-9m24-buenos-resultados-que-apuntan-a-que-puede-batirse-el-guidance-2024	1097	5	2025-11-04 21:58:41.266174	2025-11-05 08:20:25.319962	\N	\N	f	\N	t	4	f
1548	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0112501012/2	1097	5	2025-11-04 21:58:43.822659	2025-11-05 08:20:26.467329	\N	\N	f	\N	t	4	f
1549	https://www.r4.com/articulos-y-analisis/valores/tubacex-2024-fuerte-mejora-del-dividendo-con-unas-muy-positivas-perspectivas-para-2025	1107	5	2025-11-04 21:58:46.012217	2025-11-05 08:20:28.601126	\N	\N	f	\N	t	4	f
1550	https://www.r4.com/articulos-y-analisis/valores/tubacex-previo-2024-ano-de-consolidacion-previo-al-impulso-de-abu-dabi	1107	5	2025-11-04 21:58:47.192764	2025-11-05 08:20:29.77594	\N	\N	f	\N	t	4	f
1551	https://www.r4.com/articulos-y-analisis/valores/tubacex-contrato-de-octg-en-brasil	1107	5	2025-11-04 21:58:49.759764	2025-11-05 08:20:30.938253	\N	\N	f	\N	t	4	f
1552	https://www.r4.com/articulos-y-analisis/valores/tubacex-se-inicia-el-arranque-en-oriente-medio	1107	5	2025-11-04 21:58:52.040291	2025-11-05 08:20:32.096553	\N	\N	f	\N	t	4	f
1553	https://www.r4.com/articulos-y-analisis/valores/tubacex-firma-el-mayor-contrato-de-umbilicales	1107	5	2025-11-04 21:58:53.269564	2025-11-05 08:20:33.257421	\N	\N	f	\N	t	4	f
1555	https://www.r4.com/articulos-y-analisis/valores/tubacex-3t24-preparados-para-dar-el-salto-de-2025	1107	5	2025-11-04 21:58:56.937762	2025-11-05 08:20:35.604387	\N	\N	f	\N	t	4	f
1556	https://www.r4.com/articulos-y-analisis/valores/tubacex-previo-3t24-cumpliendo-expectativas	1107	5	2025-11-04 21:58:59.24053	2025-11-05 08:20:36.75568	\N	\N	f	\N	t	4	f
1557	https://www.r4.com/articulos-y-analisis/valores/tubacex-contrato-con-petrobras	1107	5	2025-11-04 21:59:00.419628	2025-11-05 08:20:38.912056	\N	\N	f	\N	t	4	f
1558	https://www.r4.com/articulos-y-analisis/valores/tubacex-previo-2t24-resultados-impactados-por-retrasos-en-facturacion	1107	5	2025-11-04 21:59:02.666467	2025-11-05 08:20:40.09356	\N	\N	f	\N	t	4	f
1559	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0132945017	1107	5	2025-11-04 21:59:04.916769	2025-11-05 08:20:41.259312	\N	\N	f	\N	t	4	f
1560	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0132945017/3	1107	5	2025-11-04 21:59:07.126281	2025-11-05 08:20:42.474227	\N	\N	f	\N	t	4	f
1561	https://www.r4.com/articulos-y-analisis/valores/melia-acuerdo-para-tomar-una-participacion-en-tres-hoteles	1117	5	2025-11-04 21:59:09.218206	2025-11-05 08:20:44.641302	\N	\N	f	\N	t	4	f
1562	https://www.r4.com/articulos-y-analisis/valores/sector-turismo-nuevo-record-de-viajeros-en-espana	1117	5	2025-11-04 21:59:10.391662	2025-11-05 08:20:45.901432	\N	\N	f	\N	t	4	f
1563	https://www.r4.com/articulos-y-analisis/valores/melia-hotels-el-verano-continua	1117	5	2025-11-04 21:59:12.593941	2025-11-05 08:20:47.096145	\N	\N	f	\N	t	4	f
1565	https://www.r4.com/articulos-y-analisis/valores/melia-hoteles-previo-3t24-una-buena-temporada-de-verano-con-una-comparativa-exigente-p-o-9-4-eur-sobreponderar	1117	5	2025-11-04 21:59:18.034956	2025-11-05 08:20:51.708055	\N	\N	f	\N	t	4	f
1566	https://www.r4.com/articulos-y-analisis/valores/melia-hoteles-resultados-2t-24-en-linea-vs-consenso-a-nivel-operativo-las-buenas-perspectivas-de-cara-al-verano-les-permite-mantener-la-guia-2024e-p-o-9-4-eur-sobreponderar	1117	5	2025-11-04 21:59:20.346485	2025-11-05 08:20:52.889971	\N	\N	f	\N	t	4	f
1567	https://www.r4.com/articulos-y-analisis/valores/melia-hoteles-previo-2t24-se-mantiene-el-buen-comportamiento-y-las-favorables-perspectivas-de-cara-al-verano-p-o-9-4-eur-sobreponderar	1117	5	2025-11-04 21:59:22.733959	2025-11-05 08:20:54.164953	\N	\N	f	\N	t	4	f
1568	https://www.r4.com/articulos-y-analisis/valores/melia-todo-apunta-a-un-verano-prometedor	1117	5	2025-11-04 21:59:24.989063	2025-11-05 08:20:55.396133	\N	\N	f	\N	t	4	f
1569	https://www.r4.com/articulos-y-analisis/valores/melia-hoteles-los-resultados-superan-previsiones-las-buenas-perspectivas-le-permiten-mejorar-la-guia-ebitda-2024e-p-o-en-revision-antes-7-5-eur-sobreponderar	1117	5	2025-11-04 21:59:26.222126	2025-11-05 08:20:56.615716	\N	\N	f	\N	t	4	f
1570	https://www.r4.com/articulos-y-analisis/valores/melia-hoteles-previo-1t24-se-mantiene-la-fortaleza-de-la-demanda-destacando-canarias-y-el-caribe-p-o-en-revision-antes-7-5-eur-sobreponderar	1117	5	2025-11-04 21:59:28.483707	2025-11-05 08:20:57.883947	\N	\N	f	\N	t	4	f
1571	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0176252718	1117	5	2025-11-04 21:59:30.723671	2025-11-05 08:20:59.069108	\N	\N	f	\N	t	4	f
1572	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0176252718/3	1117	5	2025-11-04 21:59:32.882332	2025-11-05 08:21:00.299975	\N	\N	f	\N	t	4	f
1573	https://www.r4.com/articulos-y-analisis/valores/unicaja-resultados-3t24-mejoran-guia-de-margen-de-intereses-y-coste-de-riesgo-sobreponderar-p-o-1-56-eur-acc	1126	5	2025-11-04 21:59:35.006661	2025-11-05 08:21:01.5153	\N	\N	f	\N	t	4	f
1707	https://www.r4.com/inversion-para-todos/que-es-la-reduflacion	1208	5	2025-11-04 22:03:29.695631	2025-11-05 08:24:24.917968	\N	\N	f	\N	t	4	f
4058	https://www.r4.com/articulos-y-analisis/valores/gestamp-3t25-pone-el-foco-en-los-margenes	1536	6	2025-11-05 08:30:52.36726	\N	\N	\N	f	\N	t	4	f
4195	https://www.r4.com/inversion-para-todos/que-es-el-scalping	1708	6	2025-11-05 08:34:21.700475	\N	\N	\N	f	\N	t	4	f
1575	https://www.r4.com/articulos-y-analisis/valores/unicaja-2024-superado-preparados-para-2025-sobreponderar-y-p-o-1-56-eur-acc-antes-en-revision	1126	5	2025-11-04 21:59:37.507028	2025-11-05 08:21:03.883034	\N	\N	f	\N	t	4	f
1576	https://www.r4.com/articulos-y-analisis/valores/unicaja-resultados-2t24-mejoran-guia-de-rote-ajustado-para-2024-recomendacion-y-p-o-en-revision	1126	5	2025-11-04 21:59:38.741488	2025-11-05 08:21:05.079936	\N	\N	f	\N	t	4	f
1577	https://www.r4.com/articulos-y-analisis/valores/sector-financiero-previo-2t24-punto-de-inflexion-para-el-margen-de-clientes	1126	5	2025-11-04 21:59:40.93106	2025-11-05 08:21:06.295071	\N	\N	f	\N	t	4	f
1578	https://www.r4.com/articulos-y-analisis/valores/sector-financiero-el-banco-de-espana-inicia-los-tramites-para-revisar-el-colchon-de-capital-anticiclico	1126	5	2025-11-04 21:59:43.173308	2025-11-05 08:21:07.531283	\N	\N	f	\N	t	4	f
1579	https://www.r4.com/articulos-y-analisis/valores/unicaja-resultados-1t24-reiteran-guia-de-rote-apara-2024-recomendacion-en-revision-p-o-1-07-eur-acc	1126	5	2025-11-04 21:59:44.448317	2025-11-05 08:21:08.72902	\N	\N	f	\N	t	4	f
1580	https://www.r4.com/articulos-y-analisis/valores/sector-financiero-previo-1t24-sin-sorpresas-a-la-espera-de-mayor-visibilidad	1126	5	2025-11-04 21:59:45.669217	2025-11-05 08:21:11.097547	\N	\N	f	\N	t	4	f
1581	https://www.r4.com/articulos-y-analisis/valores/unicaja-nuevos-requisitos-mrel	1126	5	2025-11-04 21:59:48.027388	2025-11-05 08:21:13.519457	\N	\N	f	\N	t	4	f
1582	https://www.r4.com/articulos-y-analisis/valores/unicaja-venta-de-activos-inmobiliarios	1126	5	2025-11-04 21:59:50.241785	2025-11-05 08:21:14.68027	\N	\N	f	\N	t	4	f
1583	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0180907000	1126	5	2025-11-04 21:59:51.442992	2025-11-05 08:21:15.862243	\N	\N	f	\N	t	4	f
1584	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0180907000/3	1126	5	2025-11-04 21:59:52.693918	2025-11-05 08:21:17.929639	\N	\N	f	\N	t	4	f
1586	https://www.r4.com/articulos-y-analisis/valores/caixabank-1t25-dinamicas-que-apoyan-unas-guias-2025-sin-cambios	1127	5	2025-11-04 21:59:56.160872	2025-11-05 08:21:22.42745	\N	\N	f	\N	t	4	f
1587	https://www.r4.com/articulos-y-analisis/valores/caixabank-plan-estrategico-2025-27-de-menos-a-mas	1127	5	2025-11-04 21:59:57.411574	2025-11-05 08:21:24.809407	\N	\N	f	\N	t	4	f
1588	https://www.r4.com/articulos-y-analisis/valores/sector-financiero-s-p-global-ratings-revisa-ratings-en-sabadell-y-caixabank	1127	5	2025-11-04 21:59:58.636	2025-11-05 08:21:25.980238	\N	\N	f	\N	t	4	f
1589	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0140609019/2	1127	5	2025-11-04 22:00:00.880775	2025-11-05 08:21:28.16954	\N	\N	f	\N	t	4	f
1590	https://www.r4.com/articulos-y-analisis/valores/santander-posible-aumento-de-los-requisitos-de-capital	1128	5	2025-11-04 22:00:02.154861	2025-11-05 08:21:30.252219	\N	\N	f	\N	t	4	f
1591	https://www.r4.com/articulos-y-analisis/valores/santander-2t25-cifras-sin-sorpresas-la-atencion-se-centrara-nuevamente-en-brasil	1128	5	2025-11-04 22:00:03.373994	2025-11-05 08:21:32.461178	\N	\N	f	\N	t	4	f
1592	https://www.r4.com/articulos-y-analisis/valores/santander-acuerdo-con-sabadell-para-la-compra-de-tsb	1128	5	2025-11-04 22:00:04.641642	2025-11-05 08:21:33.610416	\N	\N	f	\N	t	4	f
1593	https://www.r4.com/articulos-y-analisis/valores/venta-del-49-de-santander-polska-y-acuerdo-estrategico-con-erste	1128	5	2025-11-04 22:00:07.028305	2025-11-05 08:21:35.838287	\N	\N	f	\N	t	4	f
1594	https://www.r4.com/articulos-y-analisis/valores/santander-1t25-cifras-alienadas-con-objetivos-atentos-a-brasil	1128	5	2025-11-04 22:00:09.321923	2025-11-05 08:21:38.021741	\N	\N	f	\N	t	4	f
1595	https://www.r4.com/articulos-y-analisis/valores/santander-posible-venta-de-un-49-de-santander-bank-polska	1128	5	2025-11-04 22:00:10.623013	2025-11-05 08:21:40.202145	\N	\N	f	\N	t	4	f
1596	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0113900J37/2	1128	5	2025-11-04 22:00:12.91124	2025-11-05 08:21:42.56283	\N	\N	f	\N	t	4	f
1597	https://www.r4.com/articulos-y-analisis/valores/solaria-1t25-resultados-impulsados-por-la-operacion-en-generia	1129	5	2025-11-04 22:00:14.195881	2025-11-05 08:21:44.75876	\N	\N	f	\N	t	4	f
1598	https://www.r4.com/articulos-y-analisis/valores/solaria-importantes-catalizadores-en-el-horizonte	1129	5	2025-11-04 22:00:15.500819	2025-11-05 08:21:46.864242	\N	\N	f	\N	t	4	f
1599	https://www.r4.com/articulos-y-analisis/valores/solaria-4t24-ajustes-extraordinarios-para-cumplir-con-el-guidance-del-ejercicio	1129	5	2025-11-04 22:00:16.776447	2025-11-05 08:21:49.284197	\N	\N	f	\N	t	4	f
1600	https://www.r4.com/articulos-y-analisis/valores/solaria-3t24-los-bajos-precios-de-la-electricidad-lastran-los-resultados	1129	5	2025-11-04 22:00:19.041446	2025-11-05 08:21:51.464446	\N	\N	f	\N	t	4	f
4677	http://r4.com/normativa/politica-privacidad	4480	8	2025-11-05 08:48:14.107352	\N	\N	\N	f	\N	t	4	f
1601	https://www.r4.com/articulos-y-analisis/valores/solaria-2t24-recorta-la-guia-para-2024-y-2025-opcionalidad-positiva-en-data-centers	1129	5	2025-11-04 22:00:20.281172	2025-11-05 08:21:53.658505	\N	\N	f	\N	t	4	f
1602	https://www.r4.com/articulos-y-analisis/valores/solaria-1t24-bajos-precios-de-la-energia-y-retrasos-en-la-construccion-de-nueva-capacidad	1129	5	2025-11-04 22:00:22.559794	2025-11-05 08:21:55.869388	\N	\N	f	\N	t	4	f
1604	https://www.r4.com/articulos-y-analisis/valores/solaria-las-recientes-caidas-generan-una-nueva-oportunidad-de-compra	1129	5	2025-11-04 22:00:27.450913	2025-11-05 08:21:59.176091	\N	\N	f	\N	t	4	f
1605	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0165386014/2	1129	5	2025-11-04 22:00:28.691267	2025-11-05 08:22:00.352887	\N	\N	f	\N	t	4	f
1606	https://www.r4.com/articulos-y-analisis/valores/inmobiliaria-del-sur-2t25-1s25-solidez-comercial-e-impacto-positivo-en-valoracion-de-activos	1130	5	2025-11-04 22:00:30.670443	2025-11-05 08:22:01.497057	\N	\N	f	\N	t	4	f
1607	https://www.r4.com/articulos-y-analisis/valores/inmobiliaria-del-sur-previo-2t25-1s25-cifras-por-debajo-de-1s24-pero-con-visibilidad-operativa	1130	5	2025-11-04 22:00:31.95751	2025-11-05 08:22:02.667298	\N	\N	f	\N	t	4	f
1608	https://www.r4.com/articulos-y-analisis/valores/promotoras-visibilidad-operativa-a-medio-plazo	1130	5	2025-11-04 22:00:34.518194	2025-11-05 08:22:03.822189	\N	\N	f	\N	t	4	f
1609	https://www.r4.com/articulos-y-analisis/valores/inmobiliaria-del-sur-1t25-cartera-de-preventas-en-maximos-historicos	1130	5	2025-11-04 22:00:36.948172	2025-11-05 08:22:05.018177	\N	\N	f	\N	t	4	f
1610	https://www.r4.com/articulos-y-analisis/valores/inmobiliaria-del-sur-previo-1t25-menores-entregas-pero-actividad-comercial-record	1130	5	2025-11-04 22:00:39.431185	2025-11-05 08:22:06.174382	\N	\N	f	\N	t	4	f
1611	https://www.r4.com/articulos-y-analisis/valores/inmobiliaria-del-sur-incremento-de-actividad-en-el-ultimo-ano-de-su-plan-estrategico	1130	5	2025-11-04 22:00:40.677375	2025-11-05 08:22:07.314952	\N	\N	f	\N	t	4	f
1612	https://www.r4.com/articulos-y-analisis/valores/promotoras-momentum-sectorial-pero-con-valoraciones-cada-vez-mas-ajustadas	1130	5	2025-11-04 22:00:41.853838	2025-11-05 08:22:08.525731	\N	\N	f	\N	t	4	f
1613	https://www.r4.com/articulos-y-analisis/valores/promotoras-las-principales-promotoras-acumulan-unicamente-el-15-de-los-suelos-necesarios-para-cubrir-el-deficit-de-viviendas	1130	5	2025-11-04 22:00:44.367148	2025-11-05 08:22:09.665012	\N	\N	f	\N	t	4	f
1614	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0154653911/2	1130	5	2025-11-04 22:00:46.709236	2025-11-05 08:22:10.844236	\N	\N	f	\N	t	4	f
1615	https://www.r4.com/articulos-y-analisis/valores/vidrala-pre-2t25-la-gestion-como-mejor-arma-ante-la-debil-demanda	1131	5	2025-11-04 22:00:49.035403	2025-11-05 08:22:12.028619	\N	\N	f	\N	t	4	f
1977	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-a-dar-el-salta-con-el-plan-estrategico	1538	6	2025-11-04 22:11:30.079427	2025-11-05 08:30:59.416683	\N	\N	f	\N	t	4	f
1617	https://www.r4.com/articulos-y-analisis/valores/vidrala-en-busca-de-mayor-crecimiento-al-otro-lado-del-atlantico	1131	5	2025-11-04 22:00:53.770786	2025-11-05 08:22:14.503162	\N	\N	f	\N	t	4	f
1618	https://www.r4.com/articulos-y-analisis/valores/vidrala-4t24-supera-las-previsiones-en-un-trimestre-con-una-comparativa-asequible	1131	5	2025-11-04 22:00:54.982415	2025-11-05 08:22:15.697223	\N	\N	f	\N	t	4	f
1619	https://www.r4.com/articulos-y-analisis/valores/vidrala-pre-4t24-unos-beneficios-record-permiten-despalancar-el-balance	1131	5	2025-11-04 22:00:56.253737	2025-11-05 08:22:16.967497	\N	\N	f	\N	t	4	f
1621	https://www.r4.com/articulos-y-analisis/valores/vidrala-pre-2t24-la-demanda-aun-no-compensa-los-menores-precios	1131	5	2025-11-04 22:01:00.630317	2025-11-05 08:22:20.38891	\N	\N	f	\N	t	4	f
1622	https://www.r4.com/articulos-y-analisis/valores/vidrala-actualizamos-la-recomendacion-tras-alcanzar-nuestro-precio-objetivo	1131	5	2025-11-04 22:01:01.838772	2025-11-05 08:22:21.600919	\N	\N	f	\N	t	4	f
1623	https://www.r4.com/articulos-y-analisis/valores/vidrala-1t24-buen-arranque-con-la-nueva-estructura	1131	5	2025-11-04 22:01:03.223221	2025-11-05 08:22:22.896124	\N	\N	f	\N	t	4	f
1624	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0183746314/2	1131	5	2025-11-04 22:01:05.544557	2025-11-05 08:22:25.094983	\N	\N	f	\N	t	4	f
1625	https://www.r4.com/articulos-y-analisis/valores/ence-3t25-extraordinarios-maquillan-los-numeros-en-un-trimestre-complejo-nuevos-negocios-y-plan-de-eficiencia-y-competitividad-para-reforzar-el-futuro	1132	5	2025-11-04 22:01:07.770817	2025-11-05 08:22:26.316765	\N	\N	f	\N	t	4	f
1626	https://www.r4.com/articulos-y-analisis/valores/ence-huelga-de-transportistas	1132	5	2025-11-04 22:01:10.258785	2025-11-05 08:22:28.57989	\N	\N	f	\N	t	4	f
1627	https://www.r4.com/articulos-y-analisis/valores/ence-2t25-posicionandose-para-el-futuro-en-un-ano-complicado	1132	5	2025-11-04 22:01:11.477417	2025-11-05 08:22:29.823505	\N	\N	f	\N	t	4	f
1628	https://www.r4.com/articulos-y-analisis/valores/ence-2t25-reducidos-margenes-en-un-complejo-entorno-de-mercado-avanzando-en-nuevos-negocios	1132	5	2025-11-04 22:01:13.841038	2025-11-05 08:22:31.081215	\N	\N	f	\N	t	4	f
1629	https://www.r4.com/articulos-y-analisis/valores/ence-previo-2t25-diversificando-productos-y-negocios-para-paliar-la-debilidad-del-mercado	1132	5	2025-11-04 22:01:16.060507	2025-11-05 08:22:33.264299	\N	\N	f	\N	t	4	f
1630	https://www.r4.com/articulos-y-analisis/valores/ence-el-tribunal-constitucional-admite-a-tramite-el-recurso-de-amparo-del-concello-de-pontevedra	1132	5	2025-11-04 22:01:18.552687	2025-11-05 08:22:35.643228	\N	\N	f	\N	t	4	f
1631	https://www.r4.com/articulos-y-analisis/valores/ence-1t25-efectos-temporales-positivos-y-negativos-en-un-negocio-en-transformacion	1132	5	2025-11-04 22:01:20.912516	2025-11-05 08:22:36.86315	\N	\N	f	\N	t	4	f
1632	https://www.r4.com/articulos-y-analisis/valores/ence-previo-1t25-esperamos-un-2025-de-menos-a-mas	1132	5	2025-11-04 22:01:23.364875	2025-11-05 08:22:38.059419	\N	\N	f	\N	t	4	f
1633	https://www.r4.com/articulos-y-analisis/valores/ence-4t24-2024-avanzando-en-eficiencia-sostenibilidad-y-diversificacion	1132	5	2025-11-04 22:01:24.615139	2025-11-05 08:22:40.256145	\N	\N	f	\N	t	4	f
1634	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0130625512/2	1132	5	2025-11-04 22:01:27.059513	2025-11-05 08:22:42.485111	\N	\N	f	\N	t	4	f
1635	https://www.r4.com/articulos-y-analisis/valores/indra-previo-visibilidad-elevada-posible-revision-al-alza-de-objetivos	1133	5	2025-11-04 22:01:29.339073	2025-11-05 08:22:44.559659	\N	\N	f	\N	t	4	f
1636	https://www.r4.com/articulos-y-analisis/valores/indra-el-gobierno-asigna-la-mayor-parte-del-presupuesto-de-prestamos-de-defensa-a-indra	1133	5	2025-11-04 22:01:31.758551	2025-11-05 08:22:45.712631	\N	\N	f	\N	t	4	f
1637	https://www.r4.com/articulos-y-analisis/valores/indra-gana-el-concurso-de-ticketing-del-metro-de-londres	1133	5	2025-11-04 22:01:32.955017	2025-11-05 08:22:46.914696	\N	\N	f	\N	t	4	f
1639	https://www.r4.com/articulos-y-analisis/valores/indra-visibilidad-elevada-y-atencion-en-operaciones-corporativas	1133	5	2025-11-04 22:01:37.905647	2025-11-05 08:22:51.619022	\N	\N	f	\N	t	4	f
1640	https://www.r4.com/articulos-y-analisis/valores/indra-segun-prensa-esta-negociando-la-venta-de-bpo	1133	5	2025-11-04 22:01:39.067811	2025-11-05 08:22:53.980307	\N	\N	f	\N	t	4	f
1641	https://www.r4.com/articulos-y-analisis/valores/indra-salida-de-d-luis-abril-y-propuestas-jga	1133	5	2025-11-04 22:01:40.224489	2025-11-05 08:22:55.215988	\N	\N	f	\N	t	4	f
1642	https://www.r4.com/articulos-y-analisis/valores/indra-resultados-1t-25-que-incumplen-previsiones-mantiene-la-guia-2025e	1133	5	2025-11-04 22:01:42.694682	2025-11-05 08:22:57.385275	\N	\N	f	\N	t	4	f
1643	https://www.r4.com/articulos-y-analisis/valores/indra-buen-comienzo-de-ano-foco-en-operaciones-corporativas	1133	5	2025-11-04 22:01:43.888566	2025-11-05 08:22:58.568167	\N	\N	f	\N	t	4	f
1644	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0118594417/2	1133	5	2025-11-04 22:01:45.084197	2025-11-05 08:22:59.789537	\N	\N	f	\N	t	4	f
1645	https://www.r4.com/articulos-y-analisis/valores/dia-previo-avance-ventas-3t25-ejecutando-el-plan-a-la-espera-de-argentina	1136	5	2025-11-04 22:01:47.251171	2025-11-05 08:23:01.85888	\N	\N	f	\N	t	4	f
1646	https://www.r4.com/articulos-y-analisis/valores/iberdrola-9m25-superan-previsiones-y-revisan-al-alza-la-guia-2025	1136	5	2025-11-04 22:01:48.487568	2025-11-05 08:23:03.107688	\N	\N	f	\N	t	4	f
1647	https://www.r4.com/articulos-y-analisis/valores/5	1136	5	2025-11-04 22:01:49.734014	2025-11-05 08:23:04.297536	\N	\N	f	\N	t	4	f
1648	https://www.r4.com/articulos-y-analisis/valores/gestamp-cierra-la-entrada-de-un-fondo-propiedad-de-santander-en-sus-activos-inmobiliarios	1140	5	2025-11-04 22:01:51.037506	2025-11-05 08:23:05.516761	\N	\N	f	\N	t	4	f
1649	https://www.r4.com/articulos-y-analisis/valores/gestamp-santander-invertira-en-activos-inmobiliarios-del-grupo-en-espana	1140	5	2025-11-04 22:01:52.357416	2025-11-05 08:23:06.68266	\N	\N	f	\N	t	4	f
1650	https://www.r4.com/articulos-y-analisis/valores/gestamp-2t25-gran-mejora-de-margenes-en-un-entorno-de-mercado-complejo	1140	5	2025-11-04 22:01:53.572879	2025-11-05 08:23:07.937957	\N	\N	f	\N	t	4	f
1651	https://www.r4.com/articulos-y-analisis/valores/gestamp-pre-2t25-se-mantienen-las-dinamicas-negativas-en-eu-y-na	1140	5	2025-11-04 22:01:54.850496	2025-11-05 08:23:09.127257	\N	\N	f	\N	t	4	f
1652	https://www.r4.com/articulos-y-analisis/valores/gestamp-1t25-mantiene-resultados-en-un-entorno-adverso	1140	5	2025-11-04 22:01:56.123948	2025-11-05 08:23:10.319018	\N	\N	f	\N	t	4	f
1653	https://www.r4.com/articulos-y-analisis/valores/gestamp-compania-lider-en-proceso-de-recuperacion	1140	5	2025-11-04 22:01:57.440634	2025-11-05 08:23:11.500403	\N	\N	f	\N	t	4	f
1654	https://www.r4.com/articulos-y-analisis/valores/gestamp-4t24-enciende-las-luces-de-posicion	1140	5	2025-11-04 22:01:58.679892	2025-11-05 08:23:12.69504	\N	\N	f	\N	t	4	f
1655	https://www.r4.com/articulos-y-analisis/valores/gestamp-2t24-en-linea-con-el-mercado	1140	5	2025-11-04 22:01:59.904338	2025-11-05 08:23:13.884895	\N	\N	f	\N	t	4	f
1656	https://www.r4.com/articulos-y-analisis/valores/gestamp-pre-2t24-no-tendra-facil-cumplir-las-estimaciones-del-consenso-en-2024	1140	5	2025-11-04 22:02:01.160561	2025-11-05 08:23:15.135583	\N	\N	f	\N	t	4	f
1657	https://www.r4.com/articulos-y-analisis/valores/gestamp-1t24-en-linea-con-el-mercado	1140	5	2025-11-04 22:02:03.486668	2025-11-05 08:23:16.306281	\N	\N	f	\N	t	4	f
1658	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105223004/2	1140	5	2025-11-04 22:02:04.734543	2025-11-05 08:23:17.49807	\N	\N	f	\N	t	4	f
4176	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-eeuu-acciones-fi-a-cierre-de-julio-de-2025	1680	6	2025-11-05 08:33:47.93697	\N	\N	\N	f	\N	t	4	f
1660	https://www.r4.com/articulos-y-analisis/tecnico/lo-que-esta-haciendo-arcelormittal-es-historico-y-habria-que-comprar	1149	5	2025-11-04 22:02:07.236418	2025-11-05 08:23:19.993446	\N	\N	f	\N	t	4	f
1661	https://www.r4.com/articulos-y-analisis/tecnico/reacciones-del-s-p500-a-los-ultimos-cuatro-cierres-de-gobierno	1149	5	2025-11-04 22:02:08.459227	2025-11-05 08:23:21.173419	\N	\N	f	\N	t	4	f
1662	https://www.r4.com/articulos-y-analisis/tecnico/jd-com-e-intel	1149	5	2025-11-04 22:02:10.647553	2025-11-05 08:23:22.463239	\N	\N	f	\N	t	4	f
1663	https://www.r4.com/articulos-y-analisis/tecnico/ism-la-clave-en-la-extension-del-ciclo-alcista-en-las-bolsas	1149	5	2025-11-04 22:02:11.894056	2025-11-05 08:23:23.657509	\N	\N	f	\N	t	4	f
1665	https://www.r4.com/articulos-y-analisis/tecnico/el-perfecto-canal-alcista-de-largo-plazo-de-deutsche-telekom	1149	5	2025-11-04 22:02:15.320116	2025-11-05 08:23:26.087489	\N	\N	f	\N	t	4	f
1666	https://www.r4.com/articulos-y-analisis/tecnico/la-portuguesa-altri-cercana-a-generar-una-senal-de-compra-de-corto-plazo	1149	5	2025-11-04 22:02:16.555715	2025-11-05 08:23:27.320567	\N	\N	f	\N	t	4	f
1667	https://www.r4.com/articulos-y-analisis/tecnico/arcelormittal-sin-hacer-ruido-aproximandose-a-resistencias-importantisimas	1149	5	2025-11-04 22:02:18.899502	2025-11-05 08:23:28.53637	\N	\N	f	\N	t	4	f
1668	https://www.r4.com/articulos-y-analisis/tecnico/las-mineras-de-bitcoin-estan-rompiendo-y-cleanspark-promete	1149	5	2025-11-04 22:02:20.121441	2025-11-05 08:23:29.816645	\N	\N	f	\N	t	4	f
1669	https://www.r4.com/articulos-y-analisis/tecnico/5	1149	5	2025-11-04 22:02:21.382237	2025-11-05 08:23:31.061518	\N	\N	f	\N	t	4	f
1670	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-global-dynamic-fi-a-cierre-de-agosto-de-2025	1160	5	2025-11-04 22:02:22.681398	2025-11-05 08:23:32.263377	\N	\N	f	\N	t	4	f
1671	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-megatendencias-consumo-a-cierre-de-agosto-de-2025	1160	5	2025-11-04 22:02:24.91285	2025-11-05 08:23:33.507383	\N	\N	f	\N	t	4	f
1672	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-small-caps-global-a-cierre-de-agosto-de-2025	1160	5	2025-11-04 22:02:27.239032	2025-11-05 08:23:34.707791	\N	\N	f	\N	t	4	f
1673	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-renta-fija-mixto-a-cierre-de-agosto-de-2025	1160	5	2025-11-04 22:02:28.468275	2025-11-05 08:23:35.906708	\N	\N	f	\N	t	4	f
1674	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-alpha-global-a-cierre-de-agosto-de-2025	1160	5	2025-11-04 22:02:29.752521	2025-11-05 08:23:37.108438	\N	\N	f	\N	t	4	f
1675	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-pegasus-a-cierre-de-julio-de-2025	1160	5	2025-11-04 22:02:32.032461	2025-11-05 08:23:38.31256	\N	\N	f	\N	t	4	f
1676	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-nexus-a-cierre-de-julio-de-2025	1160	5	2025-11-04 22:02:34.431141	2025-11-05 08:23:39.49663	\N	\N	f	\N	t	4	f
1677	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-cripto-a-cierre-de-julio-de-2025	1160	5	2025-11-04 22:02:35.723402	2025-11-05 08:23:40.696465	\N	\N	f	\N	t	4	f
1678	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-global-dynamic-fi-a-cierre-de-julio-de-2025	1160	5	2025-11-04 22:02:37.90987	2025-11-05 08:23:41.888435	\N	\N	f	\N	t	4	f
1679	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-latinoamerica-a-cierre-de-julio-de-2025	1160	5	2025-11-04 22:02:40.487581	2025-11-05 08:23:43.363636	\N	\N	f	\N	t	4	f
1680	https://www.r4.com/articulos-y-analisis/fondos/5	1160	5	2025-11-04 22:02:42.738135	2025-11-05 08:23:44.694963	\N	\N	f	\N	t	4	f
1681	https://www.r4.com/articulos-y-analisis/cripto/los-cambios-regulatorios-y-powell-marcan-la-semana	1171	5	2025-11-04 22:02:44.888975	2025-11-05 08:23:45.972467	\N	\N	f	\N	t	4	f
1683	https://www.r4.com/articulos-y-analisis/cripto/deepseek-sacude-wall-street-y-trump-redefine-el-rumbo-cripto	1171	5	2025-11-04 22:02:47.381947	2025-11-05 08:23:48.655872	\N	\N	f	\N	t	4	f
1684	https://www.r4.com/articulos-y-analisis/cripto/trump-bitcoin-y-la-nueva-era-cripto-entre-la-volatilidad-y-la-transformacion	1171	5	2025-11-04 22:02:49.650395	2025-11-05 08:23:49.904106	\N	\N	f	\N	t	4	f
1685	https://www.r4.com/articulos-y-analisis/cripto/que-esperamos-de-los-activos-digitales-en-2025	1171	5	2025-11-04 22:02:51.94125	2025-11-05 08:23:51.148923	\N	\N	f	\N	t	4	f
1686	https://www.r4.com/articulos-y-analisis/cripto/bitcoin-entre-la-macroeconomia-y-la-computacion-cuantica-riesgo-o-evolución	1171	5	2025-11-04 22:02:53.21917	2025-11-05 08:23:52.381873	\N	\N	f	\N	t	4	f
1687	https://www.r4.com/articulos-y-analisis/cripto/bitcoin-records-y-concentracion-hacia-la-adopcion-masiva-o-la-centralizacion	1171	5	2025-11-04 22:02:54.487127	2025-11-05 08:23:53.569924	\N	\N	f	\N	t	4	f
1688	https://www.r4.com/articulos-y-analisis/cripto/bitcoin-corrige-pero-las-altcoins-toman-el-protagonismo-inicio-de-la-alt-season	1171	5	2025-11-04 22:02:56.752781	2025-11-05 08:23:54.815913	\N	\N	f	\N	t	4	f
1689	https://www.r4.com/inversion-para-todos/origen-black-friday	1176	5	2025-11-04 22:02:59.110559	2025-11-05 08:23:56.062634	\N	\N	f	\N	t	4	f
1690	https://www.r4.com/inversion-para-todos/consejos-contabilidad-domestica	1176	5	2025-11-04 22:03:01.744746	2025-11-05 08:23:58.39689	\N	\N	f	\N	t	4	f
1691	https://www.r4.com/servicios-gestion/ahorro-por-objetivos	1180	5	2025-11-04 22:03:03.519255	2025-11-05 08:24:00.146933	\N	\N	f	\N	t	4	f
1692	https://www.r4.com/inversion-para-todos/conoce-los-diferentes-tipos-de-bonos-en-los-que-invertir	1183	5	2025-11-04 22:03:04.767827	2025-11-05 08:24:01.373046	\N	\N	f	\N	t	4	f
1693	https://www.r4.com/inversion-para-todos/que-pasa-con-la-renta-fija-si-suben-los-tipos-de-interes	1184	5	2025-11-04 22:03:06.290472	2025-11-05 08:24:03.078378	\N	\N	f	\N	t	4	f
1694	https://www.r4.com/broker-online/productos-de-inversion/renta-fija/letras-del-tesoro?soc=blogr4:letesoro:texto	1184	5	2025-11-04 22:03:08.09866	2025-11-05 08:24:05.046547	\N	\N	f	\N	t	4	f
1695	https://www.r4.com/servicios-gestion/planificacion-financiera?soc=blogr4:plfinanciera:texto	1186	5	2025-11-04 22:03:09.283166	2025-11-05 08:24:06.30437	\N	\N	f	\N	t	4	f
1696	https://www.r4.com/inversion-para-todos/como-controlar-gastos-mensuales	1187	5	2025-11-04 22:03:11.255818	2025-11-05 08:24:07.526386	\N	\N	f	\N	t	4	f
1697	https://www.r4.com/renta-fija/letras-del-tesoro?soc=blogr4:letesoro:texto	1190	5	2025-11-04 22:03:12.750754	2025-11-05 08:24:09.233248	\N	\N	f	\N	t	4	f
1698	https://www.r4.com/inversion-para-todos/sistema-de-pensiones-en-espana	1192	5	2025-11-04 22:03:14.009689	2025-11-05 08:24:10.449714	\N	\N	f	\N	t	4	f
1700	https://www.r4.com/inversion-para-todos/que-es-la-inflacion-subyacente-y-como-te-afecta	1208	5	2025-11-04 22:03:17.402085	2025-11-05 08:24:13.589301	\N	\N	f	\N	t	4	f
1701	https://www.r4.com/inversion-para-todos/historia-y-curiosidades-sobre-la-paga-extra	1208	5	2025-11-04 22:03:19.162937	2025-11-05 08:24:15.264298	\N	\N	f	\N	t	4	f
1702	https://www.r4.com/inversion-para-todos/el-momento-minsky	1208	5	2025-11-04 22:03:20.893842	2025-11-05 08:24:16.89916	\N	\N	f	\N	t	4	f
1703	https://www.r4.com/inversion-para-todos/que-es-la-mano-invisible-de-la-economia	1208	5	2025-11-04 22:03:22.401827	2025-11-05 08:24:18.60402	\N	\N	f	\N	t	4	f
1704	https://www.r4.com/inversion-para-todos/que-es-el-build-to-rent	1208	5	2025-11-04 22:03:23.9856	2025-11-05 08:24:20.319054	\N	\N	f	\N	t	4	f
1705	https://www.r4.com/inversion-para-todos/el-indice-big-mac	1208	5	2025-11-04 22:03:25.947682	2025-11-05 08:24:21.829783	\N	\N	f	\N	t	4	f
1987	https://www.r4.com/articulos-y-analisis/valores/ebro-foods-1t24-excelentes-resultados-una-vez-mas-de-una-excelente-compania-que-todavia-no-tiene-reflejo-en-la-cotizacion	1548	6	2025-11-04 22:11:45.347656	2025-11-05 08:31:11.57667	\N	\N	f	\N	t	4	f
1709	https://www.r4.com/inversion-para-todos/indice-dax-40-valores	1212	5	2025-11-04 22:03:33.218586	2025-11-05 08:24:28.444262	\N	\N	f	\N	t	4	f
1710	https://www.r4.com/inversion-para-todos/que-es-swing-trading	1214	5	2025-11-04 22:03:34.915803	2025-11-05 08:24:30.153292	\N	\N	f	\N	t	4	f
1711	https://www.r4.com/inversion-para-todos/que-son-mercados-emergentes	1214	5	2025-11-04 22:03:36.867628	2025-11-05 08:24:31.654357	\N	\N	f	\N	t	4	f
1713	https://www.r4.com/inversion-para-todos/que-son-los-hedge-funds	1214	5	2025-11-04 22:03:40.078314	2025-11-05 08:24:34.698665	\N	\N	f	\N	t	4	f
1714	https://www.r4.com/inversion-para-todos/recuperacion-economica-u-v-l	1214	5	2025-11-04 22:03:41.566557	2025-11-05 08:24:36.395477	\N	\N	f	\N	t	4	f
1715	https://www.r4.com/inversion-para-todos/teoria-cisne-negro-economia	1214	5	2025-11-04 22:03:43.259946	2025-11-05 08:24:38.47958	\N	\N	f	\N	t	4	f
1716	https://www.r4.com/inversion-para-todos/sectores-inversion-bolsa	1214	5	2025-11-04 22:03:45.352319	2025-11-05 08:24:40.098036	\N	\N	f	\N	t	4	f
1717	https://www.r4.com/inversion-para-todos/cop25-inversion-sostenible	1214	5	2025-11-04 22:03:46.898344	2025-11-05 08:24:41.689718	\N	\N	f	\N	t	4	f
1718	https://www.r4.com/inversion-para-todos/que-es-japonizacion-economia	1214	5	2025-11-04 22:03:48.438155	2025-11-05 08:24:43.263724	\N	\N	f	\N	t	4	f
1719	https://www.r4.com/inversion-para-todos/que-son-los-bancos-centrales	1214	5	2025-11-04 22:03:50.177271	2025-11-05 08:24:45.212816	\N	\N	f	\N	t	4	f
1720	https://www.r4.com/inversion-para-todos/burbuja-de-las-puntocom	1214	5	2025-11-04 22:03:52.784141	2025-11-05 08:24:46.74393	\N	\N	f	\N	t	4	f
1721	https://www.r4.com/inversion-para-todos/inversion-poder-gris	1214	5	2025-11-04 22:03:54.610729	2025-11-05 08:24:48.240718	\N	\N	f	\N	t	4	f
1723	https://www.r4.com/inversion-para-todos/dividendos-volatilidad	1226	5	2025-11-04 22:03:57.518232	2025-11-05 08:24:51.088054	\N	\N	f	\N	t	4	f
1724	https://www.r4.com/inversion-para-todos/calcular-pension-jubilacion	1230	5	2025-11-04 22:03:59.080854	2025-11-05 08:24:52.990791	\N	\N	f	\N	t	4	f
1725	https://www.r4.com/inversion-para-todos/las-ventajas-de-invertir-en-verano	1232	5	2025-11-04 22:04:00.705283	2025-11-05 08:24:54.694993	\N	\N	f	\N	t	4	f
1726	https://www.r4.com/inversion-para-todos/que-son-ordenes-stop	1232	5	2025-11-04 22:04:02.236647	2025-11-05 08:24:56.234515	\N	\N	f	\N	t	4	f
1727	https://www.r4.com/inversion-para-todos/correccion-de-los-mercados-bursatiles	1242	5	2025-11-04 22:04:03.82475	2025-11-05 08:24:57.826429	\N	\N	f	\N	t	4	f
1728	https://www.r4.com/inversion-para-todos/que-son-los-analisis-top-down-y-bottom-up	1242	5	2025-11-04 22:04:05.503792	2025-11-05 08:24:59.397781	\N	\N	f	\N	t	4	f
1729	https://www.r4.com/inversion-para-todos/conoces-lo-que-son-las-defi-o-finanzas-descentralizadas	1242	5	2025-11-04 22:04:07.154465	2025-11-05 08:25:01.07513	\N	\N	f	\N	t	4	f
1730	https://www.r4.com/inversion-para-todos/los-bonos-ligados-a-la-inflacion	1242	5	2025-11-04 22:04:08.857315	2025-11-05 08:25:02.591023	\N	\N	f	\N	t	4	f
1731	https://www.r4.com/inversion-para-todos/7-consejos-para-superar-la-cuesta-de-enero	1242	5	2025-11-04 22:04:10.598705	2025-11-05 08:25:04.126951	\N	\N	f	\N	t	4	f
1732	https://www.r4.com/inversion-para-todos/diferencias-entre-renta-fija-y-renta-variable	1242	5	2025-11-04 22:04:12.052127	2025-11-05 08:25:06.193916	\N	\N	f	\N	t	4	f
1733	https://www.r4.com/inversion-para-todos/consejos-para-ahorrar-en-navidad	1242	5	2025-11-04 22:04:13.653066	2025-11-05 08:25:07.743071	\N	\N	f	\N	t	4	f
1734	https://www.r4.com/inversion-para-todos/como-nos-afecta-la-subida-de-los-tipos-de-interes	1242	5	2025-11-04 22:04:15.120942	2025-11-05 08:25:09.44607	\N	\N	f	\N	t	4	f
1735	https://www.r4.com/inversion-para-todos/stock-picking-o-seleccion-de-valores	1242	5	2025-11-04 22:04:16.654191	2025-11-05 08:25:10.991154	\N	\N	f	\N	t	4	f
1736	https://www.r4.com/inversion-para-todos/consejos-para-invertir-en-verano	1242	5	2025-11-04 22:04:18.769023	2025-11-05 08:25:12.501249	\N	\N	f	\N	t	4	f
1738	https://www.r4.com/inversion-para-todos/category/invertir-tus-ahorros/page/4	1242	5	2025-11-04 22:04:22.206044	2025-11-05 08:25:15.804346	\N	\N	f	\N	t	4	f
1739	https://www.r4.com/inversion-para-todos/como-elegir-plan-de-pensiones	1254	5	2025-11-04 22:04:23.772148	2025-11-05 08:25:17.66143	\N	\N	f	\N	t	4	f
1740	https://www.r4.com/inversion-para-todos/que-hacer-con-tu-plan-de-pensiones-una-vez-que-te-jubiles	1254	5	2025-11-04 22:04:25.484693	2025-11-05 08:25:19.195306	\N	\N	f	\N	t	4	f
1741	https://www.r4.com/inversion-para-todos/dia-educacion-financiera-2019-ciclo	1254	5	2025-11-04 22:04:27.4225	2025-11-05 08:25:20.703171	\N	\N	f	\N	t	4	f
1742	https://www.r4.com/inversion-para-todos/que-es-profundidad-de-mercado	1254	5	2025-11-04 22:04:28.989669	2025-11-05 08:25:22.368403	\N	\N	f	\N	t	4	f
1743	https://www.r4.com/inversion-para-todos/puedo-traspasar-mi-plan-de-pensiones	1254	5	2025-11-04 22:04:30.726774	2025-11-05 08:25:23.923195	\N	\N	f	\N	t	4	f
1744	https://www.r4.com/inversion-para-todos/category/invertir-tus-ahorros/page/5	1254	5	2025-11-04 22:04:32.467635	2025-11-05 08:25:25.447438	\N	\N	f	\N	t	4	f
1745	https://www.r4.com/content/rentabanco/r4/es/que-necesitas/especialista-inversion	1261	5	2025-11-04 22:04:34.220247	2025-11-05 08:25:27.271139	\N	\N	f	\N	t	4	f
1746	https://www.r4.com/normativa/seguridad	1277	5	2025-11-04 22:04:35.531907	2025-11-05 08:25:28.742136	\N	\N	f	\N	t	4	f
1747	https://www.r4.com/articulos-y-analisis/seguimiento-de-companias	1284	5	2025-11-04 22:04:36.72357	2025-11-05 08:25:29.973065	\N	\N	f	\N	t	4	f
1748	https://www.r4.com/portal?TX=company&OPC=4&ISIN=ES0105521001&MKT=MCO	1305	5	2025-11-04 22:04:37.998348	2025-11-05 08:25:31.536944	\N	\N	f	\N	t	4	f
1749	https://www.r4.com/portal?TX=company&OPC=4&ISIN=ES0180850416&MKT=MCO	1305	5	2025-11-04 22:04:39.127405	2025-11-05 08:25:32.71437	\N	\N	f	\N	t	4	f
1750	https://www.r4.com/portal?TX=company&OPC=4&ISIN=ES0134950F36&MKT=MCO	1305	5	2025-11-04 22:04:40.288601	2025-11-05 08:25:33.878423	\N	\N	f	\N	t	4	f
1752	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0132945017&MKT=MCO	1305	5	2025-11-04 22:04:42.696958	2025-11-05 08:25:36.21719	\N	\N	f	\N	t	4	f
1753	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0121975009&MKT=MCO	1305	5	2025-11-04 22:04:43.923788	2025-11-05 08:25:37.366972	\N	\N	f	\N	t	4	f
1754	https://www.r4.com/portal?TX=company&OPC=4&ISIN=ES0105630315&MKT=MCO	1305	5	2025-11-04 22:04:45.1084	2025-11-05 08:25:38.528685	\N	\N	f	\N	t	4	f
1755	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0105130001&MKT=MCO	1305	5	2025-11-04 22:04:46.321296	2025-11-05 08:25:39.746896	\N	\N	f	\N	t	4	f
1756	https://www.r4.com/conferencias/encuentro-analisis	1305	5	2025-11-04 22:04:47.560548	2025-11-05 08:25:40.935992	\N	\N	f	\N	t	4	f
1758	https://www.r4.com/articulos-y-analisis/noticias-renta4/las-piezas-moviles-en-el-puzle-de-trump-definiran-el-escenario-inversor-en-2025	1308	5	2025-11-04 22:04:51.243745	2025-11-05 08:25:43.241859	\N	\N	f	\N	t	4	f
1759	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-banco-impulsa-la-primera-opera-en-madagascar-con-un-mensaje-transformador	1308	5	2025-11-04 22:04:53.70324	2025-11-05 08:25:44.396726	\N	\N	f	\N	t	4	f
2012	https://www.r4.com/articulos-y-analisis/valores/santander-habria-contratado-a-los-colocadores-para-la-salida-a-bolsa-de-ebury-partners	1596	6	2025-11-04 22:12:32.203794	2025-11-05 08:31:43.97572	\N	\N	f	\N	t	4	f
4202	https://www.r4.com/inversion-para-todos/tipos-ordenes-bolsa	1726	6	2025-11-05 08:34:32.665833	\N	\N	\N	f	\N	t	4	f
1761	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-banco-y-fundacion-techo-aliados-en-la-lucha-contra-el-sinhogarismo-en-espana	1308	5	2025-11-04 22:04:58.327877	2025-11-05 08:25:47.881388	\N	\N	f	\N	t	4	f
1762	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-wealth-mejor-proveedor-de-vehiculos-de-wealth-management-en-los-premios-banca-privada-2024-de-citywire	1308	5	2025-11-04 22:05:00.758379	2025-11-05 08:25:49.06137	\N	\N	f	\N	t	4	f
1764	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-banco-ha-obtenido-un-beneficio-neto-de-23-2-millones-de-euros-en-los-nueve-primeros-meses-de-2024-un-20-7-mas-que-en-el-mismo-periodo-del-ano-anterior	1308	5	2025-11-04 22:05:05.369916	2025-11-05 08:25:52.467335	\N	\N	f	\N	t	4	f
1765	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-banco-y-abao-bilbao-opera-firman-un-acuerdo-de-colaboracion-para-fomentar-la-cultura-a-traves-de-la-musica	1308	5	2025-11-04 22:05:07.590907	2025-11-05 08:25:54.747612	\N	\N	f	\N	t	4	f
1766	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-banco-y-traders-business-school-celebran-el-dia-de-la-educacion-financiera-ofreciendo-los-ciclos-formativos-de-ahorrador-a-inversor	1308	5	2025-11-04 22:05:09.841636	2025-11-05 08:25:55.953669	\N	\N	f	\N	t	4	f
1767	https://www.r4.com/articulos-y-analisis/area-prensa/5	1308	5	2025-11-04 22:05:12.036909	2025-11-05 08:25:58.192505	\N	\N	f	\N	t	4	f
1768	http://www.r4.com/fondos-de-inversion/rentabilidad-fondos-de-inversion	1309	5	2025-11-04 22:05:13.980947	2025-11-05 08:25:59.409471	\N	\N	f	\N	t	4	f
1769	http://www.r4.com/serviciosr4/broker-online-para-invertir-en-bolsa-con-ventaja	1318	5	2025-11-04 22:05:15.242537	2025-11-05 08:26:00.603972	\N	\N	f	\N	t	4	f
1770	http://www.r4.com/que-necesitas/contacto	1318	5	2025-11-04 22:05:16.821472	2025-11-05 08:26:01.760553	\N	\N	f	\N	t	4	f
1771	https://www.r4.com/articulos-y-analisis/valores/sabadell-mejora-la-retribucion-al-accionista-y-rechaza-la-oferta-de-bbva	1319	6	2025-11-04 22:05:18.080973	2025-11-05 08:26:03.168236	\N	\N	f	\N	t	4	f
1772	https://www.r4.com/articulos-y-analisis/valores/sabadell-2t25-plan-estrategico-2025-27e-mejora-guia-2025-de-coste-de-riesgo-y-rote	1319	6	2025-11-04 22:05:20.42332	2025-11-05 08:26:05.556586	\N	\N	f	\N	t	4	f
1773	https://www.r4.com/articulos-y-analisis/valores/sabadell-acuerda-con-santander-la-venta-de-tsb	1319	6	2025-11-04 22:05:22.87855	2025-11-05 08:26:06.699184	\N	\N	f	\N	t	4	f
1774	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0113860A34/2	1319	6	2025-11-04 22:05:25.30648	2025-11-05 08:26:07.855283	\N	\N	f	\N	t	4	f
1775	https://www.r4.com/articulos-y-analisis/valores/bankinter-resultados-3t25-cifras-sin-sorpresas-pendientes-de-las-guias-de-margen-de-intereses-comisiones-y-gastos-infraponderar-p-o-10-16-eur-acc	1320	6	2025-11-04 22:05:27.602668	2025-11-05 08:26:10.005395	\N	\N	f	\N	t	4	f
1776	https://www.r4.com/articulos-y-analisis/valores/bankinter-2t25-se-mantiene-la-fortaleza-de-los-ingresos-recurrentes	1320	6	2025-11-04 22:05:29.846263	2025-11-05 08:26:12.356812	\N	\N	f	\N	t	4	f
1777	https://www.r4.com/articulos-y-analisis/valores/bankinter-1t25-sin-cambios-en-las-guias-del-ano-palancas-para-sostener-el-margen-de-intereses	1320	6	2025-11-04 22:05:31.035895	2025-11-05 08:26:13.496447	\N	\N	f	\N	t	4	f
1778	https://www.r4.com/articulos-y-analisis/valores/bankinter-1t25-superan-estimaciones-buenas-dinamicas-que-aportan-visibilidad-de-resultados	1320	6	2025-11-04 22:05:33.446753	2025-11-05 08:26:14.688857	\N	\N	f	\N	t	4	f
1779	https://www.r4.com/articulos-y-analisis/valores/bankinter-diversificacion-de-negocio-para-la-recurrencia-de-ingresos	1320	6	2025-11-04 22:05:35.88554	2025-11-05 08:26:15.861389	\N	\N	f	\N	t	4	f
1780	https://www.r4.com/articulos-y-analisis/valores/bankinter-la-diversificacion-gana-terreno	1320	6	2025-11-04 22:05:37.074565	2025-11-05 08:26:18.194873	\N	\N	f	\N	t	4	f
1781	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0113679I37/2	1320	6	2025-11-04 22:05:39.231523	2025-11-05 08:26:19.351828	\N	\N	f	\N	t	4	f
1782	https://www.r4.com/articulos-y-analisis/valores/bbva-4t24-las-guias-para-2025-apuntan-a-estabilidad-operativa-y-deterioro-del-coste-de-riesgo-en-mexico-y-turquia	1329	6	2025-11-04 22:05:41.290678	2025-11-05 08:26:21.442669	\N	\N	f	\N	t	4	f
1783	https://www.r4.com/articulos-y-analisis/valores/opa-sobre-sabadell-en-que-punto-nos-encontramos	1329	6	2025-11-04 22:05:43.587733	2025-11-05 08:26:22.604264	\N	\N	f	\N	t	4	f
1784	https://www.r4.com/articulos-y-analisis/valores/bbva-modificacion-de-la-oferta-sobre-la-condicion-de-aceptacion	1329	6	2025-11-04 22:05:46.017922	2025-11-05 08:26:23.749119	\N	\N	f	\N	t	4	f
1785	https://www.r4.com/articulos-y-analisis/valores/bbva-emision-de-participaciones-preferentes-eventualmente-convertibles	1329	6	2025-11-04 22:05:47.559754	2025-11-05 08:26:24.969147	\N	\N	f	\N	t	4	f
1786	https://www.r4.com/articulos-y-analisis/valores/bbva-la-opa-sobre-sabadell-no-deja-recoger-los-fundamentales	1329	6	2025-11-04 22:05:49.924229	2025-11-05 08:26:26.120762	\N	\N	f	\N	t	4	f
1787	https://www.r4.com/articulos-y-analisis/valores/bbva-la-cnmc-acuerda-iniciar-la-segunda-fase-del-analisis	1329	6	2025-11-04 22:05:52.164228	2025-11-05 08:26:28.503375	\N	\N	f	\N	t	4	f
1789	https://www.r4.com/articulos-y-analisis/valores/bbva-ajuste-de-la-ecuacion-de-canje-tras-el-pago-de-dividendo	1329	6	2025-11-04 22:05:55.733604	2025-11-05 08:26:30.770484	\N	\N	f	\N	t	4	f
1790	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0113211835/4	1329	6	2025-11-04 22:05:57.163641	2025-11-05 08:26:32.903531	\N	\N	f	\N	t	4	f
1791	https://www.r4.com/articulos-y-analisis/valores/enagas-2023-beneficio-neto-supera-objetivo-deuda-neta-mejora-nuestras-expectativas	1341	6	2025-11-04 22:05:59.449785	2025-11-05 08:26:34.889959	\N	\N	f	\N	t	4	f
1792	https://www.r4.com/articulos-y-analisis/valores/enagas-previo-2023-esperamos-que-se-alcance-la-guia-pendientes-de-guia-de-objetivos-2024	1341	6	2025-11-04 22:06:00.618011	2025-11-05 08:26:36.125447	\N	\N	f	\N	t	4	f
1793	https://www.r4.com/articulos-y-analisis/valores/naturgy-9m25-esperando-que-continue-la-tendencia-vista-en-1s	1342	6	2025-11-04 22:06:02.10165	2025-11-05 08:26:37.294458	\N	\N	f	\N	t	4	f
1794	https://www.r4.com/articulos-y-analisis/valores/naturgy-anuncia-una-colocacion-acelerada-y-una-venta-bilateral-por-el-5-5-del-capital	1342	6	2025-11-04 22:06:04.633784	2025-11-05 08:26:39.494679	\N	\N	f	\N	t	4	f
1795	https://www.r4.com/articulos-y-analisis/valores/naturgy-1s25-mejoran-expectativas-en-todas-las-lineas-del-p-l-y-en-la-deuda-neta-objetivos-2025-ligeramente-por-encima-de-expectativas	1342	6	2025-11-04 22:06:05.88448	2025-11-05 08:26:41.715888	\N	\N	f	\N	t	4	f
1796	https://www.r4.com/articulos-y-analisis/valores/naturgy-1s25-alineandose-para-alcanzar-la-media-de-ebitda-del-plan-estrategico	1342	6	2025-11-04 22:06:08.13369	2025-11-05 08:26:42.895125	\N	\N	f	\N	t	4	f
1797	https://www.r4.com/articulos-y-analisis/valores/naturgy-dividendos-atractivos-pero-sin-crecimiento-del-p-l-a-medio-plazo	1342	6	2025-11-04 22:06:10.383156	2025-11-05 08:26:45.220621	\N	\N	f	\N	t	4	f
1798	https://www.r4.com/articulos-y-analisis/valores/conclusiones-naturgy-2024-plan-2025-2027-limitan-crecimiento-por-recompra-de-acciones	1342	6	2025-11-04 22:06:12.717578	2025-11-05 08:26:46.354577	\N	\N	f	\N	t	4	f
1799	https://www.r4.com/articulos-y-analisis/valores/naturgy-2024-supera-objetivo-de-beneficio-neto-y-deuda-neta-incrementan-dividendo-a-2027	1342	6	2025-11-04 22:06:15.069627	2025-11-05 08:26:48.508428	\N	\N	f	\N	t	4	f
2014	https://www.r4.com/articulos-y-analisis/valores/santander-resultados-4t24-2025-ano-de-estabilidad-en-ingresos	1596	6	2025-11-04 22:12:35.736139	2025-11-05 08:31:47.388954	\N	\N	f	\N	t	4	f
4203	https://www.r4.com/soluciones-easy/fondos-easy	1728	6	2025-11-05 08:34:34.208366	\N	\N	\N	f	\N	t	4	f
1801	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0116870314/2	1342	6	2025-11-04 22:06:19.806324	2025-11-05 08:26:50.864006	\N	\N	f	\N	t	4	f
1802	https://www.r4.com/articulos-y-analisis/valores/previo-redeia-9m25-seguimos-cautos-en-el-corto-plazo	1343	6	2025-11-04 22:06:22.074591	2025-11-05 08:26:52.05335	\N	\N	f	\N	t	4	f
1803	https://www.r4.com/articulos-y-analisis/valores/redeia-1s25-esperando-comentarios-respecto-al-borrador-de-la-cnmc-en-la-conferencia	1343	6	2025-11-04 22:06:24.527688	2025-11-05 08:26:53.190796	\N	\N	f	\N	t	4	f
1804	https://www.r4.com/articulos-y-analisis/valores/previo-redeia-1s25-el-foco-en-los-comentarios-respecto-al-borrador-de-la-retribucion-de-la-red	1343	6	2025-11-04 22:06:26.931898	2025-11-05 08:26:55.539251	\N	\N	f	\N	t	4	f
1805	https://www.r4.com/articulos-y-analisis/valores/redeia-1t25-resultados-sin-sorpresas	1343	6	2025-11-04 22:06:29.24062	2025-11-05 08:26:57.995618	\N	\N	f	\N	t	4	f
1806	https://www.r4.com/articulos-y-analisis/valores/previo-redeia-1t25-crecimiento-moderado-esperado-sin-cambios-previstos-en-las-guias	1343	6	2025-11-04 22:06:30.451442	2025-11-05 08:26:59.128317	\N	\N	f	\N	t	4	f
1807	https://www.r4.com/articulos-y-analisis/valores/redeia-aceleracion-de-inversiones-a-la-espera-de-planificacion-y-regulacion	1343	6	2025-11-04 22:06:31.64276	2025-11-05 08:27:00.302813	\N	\N	f	\N	t	4	f
1809	https://www.r4.com/articulos-y-analisis/valores/redeia-2024-recogiendo-desconsolidacion-de-hispasat-sin-sorpresas-pendientes-de-la-guia	1343	6	2025-11-04 22:06:36.065234	2025-11-05 08:27:02.581974	\N	\N	f	\N	t	4	f
1810	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0173093024/2	1343	6	2025-11-04 22:06:38.317077	2025-11-05 08:27:03.831547	\N	\N	f	\N	t	4	f
1811	https://www.r4.com/articulos-y-analisis/valores/acciona-1s25-la-estrategia-de-rotacion-de-activos-nos-lleva-a-revisar-al-alza-nuestro-p-o	1344	6	2025-11-04 22:06:40.308132	2025-11-05 08:27:05.012326	\N	\N	f	\N	t	4	f
1812	https://www.r4.com/articulos-y-analisis/valores/acciona-informe-de-tendencias-de-negocio-1t25-sin-sorpresas-con-visibilidad-operativa-y-cumplimiento-de-objetivos	1344	6	2025-11-04 22:06:42.673765	2025-11-05 08:27:06.21568	\N	\N	f	\N	t	4	f
1813	https://www.r4.com/articulos-y-analisis/valores/acciona-un-modelo-diversificado-y-resiliente-para-navegar-la-incertidumbre	1344	6	2025-11-04 22:06:45.097581	2025-11-05 08:27:07.363988	\N	\N	f	\N	t	4	f
1814	https://www.r4.com/articulos-y-analisis/valores/acciona-4t24-cogiendo-impulso-para-2025	1344	6	2025-11-04 22:06:46.323011	2025-11-05 08:27:08.50995	\N	\N	f	\N	t	4	f
1815	https://www.r4.com/articulos-y-analisis/valores/acciona-informe-de-tendencias-de-negocio-9m24-reitera-objetivos-para-2024	1344	6	2025-11-04 22:06:47.58216	2025-11-05 08:27:10.727659	\N	\N	f	\N	t	4	f
1816	https://www.r4.com/articulos-y-analisis/valores/acciona-1s24-espera-una-fuerte-segunda-mitad-de-ejercicio-impulsada-por-la-filial-de-energia	1344	6	2025-11-04 22:06:49.821032	2025-11-05 08:27:11.912987	\N	\N	f	\N	t	4	f
1817	https://www.r4.com/articulos-y-analisis/valores/acciona-1t24-la-energia-continua-lastrando-el-buen-desempeno-del-resto-del-grupo	1344	6	2025-11-04 22:06:52.151353	2025-11-05 08:27:14.176377	\N	\N	f	\N	t	4	f
1818	https://www.r4.com/articulos-y-analisis/valores/acciona-4t23-energia-lastra-el-excelente-comportamiento-de-infraestructuras	1344	6	2025-11-04 22:06:54.63487	2025-11-05 08:27:15.395222	\N	\N	f	\N	t	4	f
1819	https://www.r4.com/articulos-y-analisis/valores/iberdrola-cmd-2025-refuerza-el-giro-hacia-negocios-regulados-y-contratos-a-largo-plazo	1345	6	2025-11-04 22:06:56.987732	2025-11-05 08:27:17.784763	\N	\N	f	\N	t	4	f
1820	https://www.r4.com/articulos-y-analisis/valores/conclusiones-iberdrola-2024-guia-2025-ligeramente-mejor-que-estimaciones	1345	6	2025-11-04 22:06:59.445252	2025-11-05 08:27:18.997049	\N	\N	f	\N	t	4	f
1821	https://www.r4.com/articulos-y-analisis/valores/iberdrola-2024-cumpliendo-con-las-previsiones	1345	6	2025-11-04 22:07:01.703108	2025-11-05 08:27:21.28411	\N	\N	f	\N	t	4	f
1822	https://www.r4.com/articulos-y-analisis/valores/iberdrola-previo-2024-ajustando-el-balance-para-conseguir-mejoras-en-el-p-l-a-medio-plazo	1345	6	2025-11-04 22:07:04.03712	2025-11-05 08:27:23.386285	\N	\N	f	\N	t	4	f
1823	https://www.r4.com/articulos-y-analisis/valores/iberdrola-excelente-posicionamiento-y-solido-balance-para-seguir-creciendo	1345	6	2025-11-04 22:07:06.28855	2025-11-05 08:27:24.585387	\N	\N	f	\N	t	4	f
1824	https://www.r4.com/articulos-y-analisis/valores/iberdrola-9m24-objetivo-2024-por-encima-de-nuestra-prevision	1345	6	2025-11-04 22:07:08.699056	2025-11-05 08:27:27.011618	\N	\N	f	\N	t	4	f
1825	https://www.r4.com/articulos-y-analisis/valores/iberdrola-previo-9m24-sin-cambios-de-objetivo-esperados-pese-al-fuerte-crecimiento-previsto	1345	6	2025-11-04 22:07:10.806163	2025-11-05 08:27:29.133497	\N	\N	f	\N	t	4	f
1826	https://www.r4.com/articulos-y-analisis/valores/iberdrola-adjudicacion-de-1-gw-en-reino-unido-en-dos-proyectos-de-eolica-marina	1345	6	2025-11-04 22:07:13.180292	2025-11-05 08:27:30.323744	\N	\N	f	\N	t	4	f
1828	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0144580Y14/2	1345	6	2025-11-04 22:07:17.674603	2025-11-05 08:27:34.959629	\N	\N	f	\N	t	4	f
1829	https://www.r4.com/articulos-y-analisis/valores/ferrovial-previo-2023-trafico-tarifas-y-perimetro-seguiran-apoyando-el-crecimiento	1368	6	2025-11-04 22:07:19.868117	2025-11-05 08:27:37.216622	\N	\N	f	\N	t	4	f
1830	https://www.r4.com/articulos-y-analisis/valores/ferrovial-un-capital-markets-day-descafeinado-no-mostro-novedades-muy-relevantes	1368	6	2025-11-04 22:07:22.077787	2025-11-05 08:27:39.591718	\N	\N	f	\N	t	4	f
1831	https://www.r4.com/articulos-y-analisis/valores/atresmedia-pre-2t25-reduce-el-beneficio-ante-una-exigente-comparativa-con-un-mercado-a-la-baja	1389	6	2025-11-04 22:07:23.356279	2025-11-05 08:27:41.82212	\N	\N	f	\N	t	4	f
1832	https://www.r4.com/articulos-y-analisis/valores/atresmedia-1t25-apuesta-por-mantener-el-liderazgo-en-entorno-de-comparativa-exigente	1389	6	2025-11-04 22:07:25.521703	2025-11-05 08:27:44.057886	\N	\N	f	\N	t	4	f
1833	https://www.r4.com/articulos-y-analisis/valores/atresmedia-la-cotizacion-se-aproxima-a-nuestro-precio-objetivo	1389	6	2025-11-04 22:07:27.09536	2025-11-05 08:27:45.285623	\N	\N	f	\N	t	4	f
1834	https://www.r4.com/articulos-y-analisis/valores/atresmedia-pre-4t24-las-plusvalias-elevan-el-beneficio	1389	6	2025-11-04 22:07:28.403147	2025-11-05 08:27:47.55803	\N	\N	f	\N	t	4	f
1835	https://www.r4.com/articulos-y-analisis/valores/atresmedia-la-recurrencia-del-dividendo-justifica-la-compra	1389	6	2025-11-04 22:07:30.674436	2025-11-05 08:27:48.786513	\N	\N	f	\N	t	4	f
1836	https://www.r4.com/articulos-y-analisis/valores/atresmedia-pre-1s24-un-primer-semestre-que-supera-las-expectativas	1389	6	2025-11-04 22:07:32.930204	2025-11-05 08:27:49.987009	\N	\N	f	\N	t	4	f
1837	https://www.r4.com/articulos-y-analisis/valores/atresmedia-toma-un-15-de-capital-de-playfilm	1389	6	2025-11-04 22:07:34.194911	2025-11-05 08:27:51.193145	\N	\N	f	\N	t	4	f
1838	https://www.r4.com/articulos-y-analisis/valores/dominion-adquiere-la-compania-ecogestion-de-residuos	1390	6	2025-11-04 22:07:36.514783	2025-11-05 08:27:52.409226	\N	\N	f	\N	t	4	f
1839	https://www.r4.com/articulos-y-analisis/valores/dominion-2t25-positiva-evolucion-operativa	1390	6	2025-11-04 22:07:37.693944	2025-11-05 08:27:53.646961	\N	\N	f	\N	t	4	f
1840	https://www.r4.com/articulos-y-analisis/valores/dominion-pre-2t25-da-un-golpe-de-efecto-reforzando-su-balance	1390	6	2025-11-04 22:07:39.963406	2025-11-05 08:27:55.863925	\N	\N	f	\N	t	4	f
2020	https://www.r4.com/articulos-y-analisis/valores/solaria-obtiene-la-autorizacion-administrativa-de-construccion-para-el-proyecto-de-garona-595-mw	1605	6	2025-11-04 22:12:46.763233	2025-11-05 08:31:58.560542	\N	\N	f	\N	t	4	f
1842	https://www.r4.com/articulos-y-analisis/valores/dominion-1t25-renueva-su-estructura-de-negocios-para-retomar-el-crecimiento	1390	6	2025-11-04 22:07:44.498896	2025-11-05 08:27:59.231549	\N	\N	f	\N	t	4	f
1843	https://www.r4.com/articulos-y-analisis/valores/dominion-avanzando-en-el-reposicionamiento-de-los-negocios	1390	6	2025-11-04 22:07:45.784958	2025-11-05 08:28:01.48541	\N	\N	f	\N	t	4	f
1844	https://www.r4.com/articulos-y-analisis/valores/dominion-4t24-reactivacion-a-la-vista	1390	6	2025-11-04 22:07:48.18931	2025-11-05 08:28:02.6355	\N	\N	f	\N	t	4	f
1846	https://www.r4.com/articulos-y-analisis/valores/dominion-se-asocia-con-equita-capital-para-construir-proyectos-fotovoltaicos-en-italia	1390	6	2025-11-04 22:07:52.837188	2025-11-05 08:28:04.980374	\N	\N	f	\N	t	4	f
1847	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105130001/2	1390	6	2025-11-04 22:07:55.024933	2025-11-05 08:28:06.159484	\N	\N	f	\N	t	4	f
1848	https://www.r4.com/articulos-y-analisis/informes-de-analisis/los-mercados-salvan-un-mes-de-enero-muy-volatil	1391	6	2025-11-04 22:07:56.222781	2025-11-05 08:28:08.148491	\N	\N	f	\N	t	4	f
1849	https://www.r4.com/articulos-y-analisis/valores/sacyr-2023-sorpresa-positiva-en-la-parte-alta-de-la-cuenta-de-resultados	1401	6	2025-11-04 22:07:58.418336	2025-11-05 08:28:09.304581	\N	\N	f	\N	t	4	f
1850	https://www.r4.com/articulos-y-analisis/valores/previo-sacyr-2023-esperamos-que-los-margenes-sigan-evolucionando-positivamente	1401	6	2025-11-04 22:08:00.577318	2025-11-05 08:28:10.482603	\N	\N	f	\N	t	4	f
1851	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-1t24-2t-en-linea-o-mejor-que-1t-mantienen-la-guia-de-demanda-2024e-p-o-35-6-eur-sobreponderar	1413	6	2025-11-04 22:08:02.80758	2025-11-05 08:28:11.680705	\N	\N	f	\N	t	4	f
1852	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-1t24-los-resultados-superan-previsiones-y-recuperan-parte-del-deterioro-de-4t-23-sin-cambios-en-la-guia-p-o-35-6-eur-sobreponderar	1413	6	2025-11-04 22:08:04.006185	2025-11-05 08:28:12.813304	\N	\N	f	\N	t	4	f
1853	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-mejora-prevista-en-1t-24-cuya-continuidad-es-incierta	1413	6	2025-11-04 22:08:06.286025	2025-11-05 08:28:13.962441	\N	\N	f	\N	t	4	f
1854	https://www.r4.com/articulos-y-analisis/valores/arcelor-mittal-anuncia-la-adquisicion-de-una-participacion-en-vallourec	1413	6	2025-11-04 22:08:08.5662	2025-11-05 08:28:15.194767	\N	\N	f	\N	t	4	f
1855	https://www.r4.com/articulos-y-analisis/valores/arcelor-mittal-el-gobierno-italiano-ha-puesto-aceria-de-italia-adi-bajo-administracion-extraordinaria	1413	6	2025-11-04 22:08:10.789391	2025-11-05 08:28:16.392094	\N	\N	f	\N	t	4	f
1856	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-conferencia-4t23-mejora-prevista-en-1t-24-p-o-35-6-eur-sobreponderar	1413	6	2025-11-04 22:08:13.148038	2025-11-05 08:28:18.687717	\N	\N	f	\N	t	4	f
1858	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-continua-el-deterioro-secuencial-en-4t-23-esperando-una-mejora-a-partir-de-1t-24-condicionada-a-la-evolucion-de-la-demanda	1413	6	2025-11-04 22:08:17.618404	2025-11-05 08:28:20.962012	\N	\N	f	\N	t	4	f
1859	https://www.r4.com/articulos-y-analisis/valores/iag-previo-se-consolida-la-recuperacion-p-o-2-53-eur-sobreponderar	1430	6	2025-11-04 22:08:18.809306	2025-11-05 08:28:22.117567	\N	\N	f	\N	t	4	f
1860	https://www.r4.com/articulos-y-analisis/valores/colonial-2t25-1s25-solidas-cifras-y-sorpresa-positiva-en-valoracion-de-activos	1431	6	2025-11-04 22:08:20.058708	2025-11-05 08:28:23.254189	\N	\N	f	\N	t	4	f
1861	https://www.r4.com/articulos-y-analisis/valores/colonial-previo-2t25-1s25-continuidad-operativa-y-ligera-mejora-en-valor-de-activos	1431	6	2025-11-04 22:08:22.252969	2025-11-05 08:28:24.434739	\N	\N	f	\N	t	4	f
1862	https://www.r4.com/articulos-y-analisis/valores/colonial-1t25-menores-gastos-de-estructura-y-financieros-impulsan-el-bo-neto-recurrente	1431	6	2025-11-04 22:08:24.54085	2025-11-05 08:28:26.759374	\N	\N	f	\N	t	4	f
1863	https://www.r4.com/articulos-y-analisis/valores/colonial-previo-1t25-solidez-operativa-pendientes-de-mas-detalles-sobre-deeplabs	1431	6	2025-11-04 22:08:25.744708	2025-11-05 08:28:27.941463	\N	\N	f	\N	t	4	f
1864	https://www.r4.com/articulos-y-analisis/valores/colonial-actualiza-su-cartera-de-proyectos-con-alpha-deeplabs-entrando-en-el-segmento-de-ciencia-e-innovacion	1431	6	2025-11-04 22:08:26.967926	2025-11-05 08:28:29.136978	\N	\N	f	\N	t	4	f
1865	https://www.r4.com/articulos-y-analisis/valores/colonial-calidad-y-crecimiento-a-buen-precio	1431	6	2025-11-04 22:08:28.241236	2025-11-05 08:28:30.290404	\N	\N	f	\N	t	4	f
1866	https://www.r4.com/articulos-y-analisis/valores/colonial-los-consejos-aprueban-el-proyecto-de-fusion-con-su-filial-francesa-sfl	1431	6	2025-11-04 22:08:30.476498	2025-11-05 08:28:31.51456	\N	\N	f	\N	t	4	f
1867	https://www.r4.com/articulos-y-analisis/valores/colonial-4t24-2024-superan-el-objetivo-de-bpa-en-un-ano-marcado-por-la-ampliacion-de-criteria	1431	6	2025-11-04 22:08:31.65523	2025-11-05 08:28:33.640291	\N	\N	f	\N	t	4	f
1868	https://www.r4.com/articulos-y-analisis/valores/colonial-previo-4t24-2024-impulso-de-rentas-para-superar-objetivos	1431	6	2025-11-04 22:08:33.850917	2025-11-05 08:28:34.819157	\N	\N	f	\N	t	4	f
1869	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0139140174/2	1431	6	2025-11-04 22:08:35.12032	2025-11-05 08:28:35.960242	\N	\N	f	\N	t	4	f
1870	https://www.r4.com/articulos-y-analisis/valores/merlin-properties-s-p-eleva-el-rating-a-bbb-con-perspectiva-estable	1443	6	2025-11-04 22:08:37.225193	2025-11-05 08:28:37.130584	\N	\N	f	\N	t	4	f
1871	https://www.r4.com/articulos-y-analisis/valores/merlin-properties-4t23-2023-cumple-su-objetivo-de-ffo-0-61-eur-accion	1443	6	2025-11-04 22:08:39.394401	2025-11-05 08:28:38.299171	\N	\N	f	\N	t	4	f
1872	https://www.r4.com/articulos-y-analisis/valores/socimis-previo-2023-festival-operativo	1443	6	2025-11-04 22:08:41.540159	2025-11-05 08:28:39.4424	\N	\N	f	\N	t	4	f
1873	https://www.r4.com/articulos-y-analisis/valores/metrovacesa-previo-3t25-trimestre-de-transicion-hacia-un-determinante-4t25	1444	6	2025-11-04 22:08:43.894511	2025-11-05 08:28:41.730439	\N	\N	f	\N	t	4	f
1874	https://www.r4.com/articulos-y-analisis/valores/metrovacesa-2t25-1s25-debil-semestre-con-reiteracion-de-objetivos-anuales	1444	6	2025-11-04 22:08:46.247652	2025-11-05 08:28:44.017536	\N	\N	f	\N	t	4	f
1875	https://www.r4.com/articulos-y-analisis/valores/metrovacesa-previo-2t25-1s25-debil-semestre	1444	6	2025-11-04 22:08:48.704419	2025-11-05 08:28:45.18239	\N	\N	f	\N	t	4	f
1876	https://www.r4.com/articulos-y-analisis/valores/metrovacesa-1t25-resultados-por-debajo-con-reiteracion-de-objetivos-anuales	1444	6	2025-11-04 22:08:50.24255	2025-11-05 08:28:46.412463	\N	\N	f	\N	t	4	f
1877	https://www.r4.com/articulos-y-analisis/valores/metrovacesa-previo-1t25-cifras-mas-debiles-por-mix-de-entregas-pero-buen-tono-comercial	1444	6	2025-11-04 22:08:51.465702	2025-11-05 08:28:49.006564	\N	\N	f	\N	t	4	f
1878	https://www.r4.com/articulos-y-analisis/valores/metrovacesa-visibilidad-valoracion-generacion-de-caja-y-angulo-corporativo	1444	6	2025-11-04 22:08:53.724777	2025-11-05 08:28:50.439765	\N	\N	f	\N	t	4	f
1879	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105122024/2	1444	6	2025-11-04 22:08:54.953623	2025-11-05 08:28:52.941621	\N	\N	f	\N	t	4	f
1880	https://www.r4.com/content/rentabanco/r4/es/servicios-gestion/planificacion-financiera/seguros-de-vida	1449	6	2025-11-04 22:08:57.33265	2025-11-05 08:28:54.141814	\N	\N	f	\N	t	4	f
2041	https://www.r4.com/articulos-y-analisis/valores/vidrala-anuncia-un-plan-de-sucesion-con-nombramiento-de-nuevo-ceo-y-la-propuesta-de-un-dividendo-extraordinario	1624	6	2025-11-04 22:13:21.55537	2025-11-05 08:32:35.483467	\N	\N	f	\N	t	4	f
1882	https://www.r4.com/articulos-y-analisis/valores/telefonica-venta-de-telefonica-del-peru	1461	6	2025-11-04 22:08:59.863202	2025-11-05 08:28:56.724579	\N	\N	f	\N	t	4	f
1883	https://www.r4.com/articulos-y-analisis/valores/telefonica-acuerdo-para-la-venta-de-telefonica-colombia	1461	6	2025-11-04 22:09:01.109164	2025-11-05 08:28:57.917714	\N	\N	f	\N	t	4	f
1884	https://www.r4.com/articulos-y-analisis/valores/telefonica-cierre-del-acuerdo-con-vodafone-espana	1461	6	2025-11-04 22:09:02.346117	2025-11-05 08:28:59.110673	\N	\N	f	\N	t	4	f
1886	https://www.r4.com/articulos-y-analisis/valores/telefonica-resultados-4t-24-ingresos-y-ebitda-subyacente-superan-previsiones-provisiones-elevadas-mejor-evolucion-de-la-deuda-neta-cumplen-guia-2024-y-guia-2025e-poco-ambiciosa	1461	6	2025-11-04 22:09:05.895985	2025-11-05 08:29:01.558532	\N	\N	f	\N	t	4	f
1887	https://www.r4.com/articulos-y-analisis/valores/telefonica-vende-telefonica-argentina	1461	6	2025-11-04 22:09:07.082775	2025-11-05 08:29:02.760948	\N	\N	f	\N	t	4	f
1888	https://www.r4.com/articulos-y-analisis/valores/telefonica-procedimiento-concursal-ordinario-en-peru	1461	6	2025-11-04 22:09:09.385928	2025-11-05 08:29:03.958408	\N	\N	f	\N	t	4	f
1889	https://www.r4.com/articulos-y-analisis/valores/telefonica-stc-completa-el-aumento-de-participacion-al-9-97	1461	6	2025-11-04 22:09:10.615936	2025-11-05 08:29:05.139547	\N	\N	f	\N	t	4	f
1890	https://www.r4.com/articulos-y-analisis/valores/telefonica-el-consejo-de-administracion-ha-aprobado-rescindir-el-contrato-con-d-jose-maria-alvarez-pallete-presidente-ejecutivo-desde-2016	1461	6	2025-11-04 22:09:12.846413	2025-11-05 08:29:06.422359	\N	\N	f	\N	t	4	f
1891	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0178430E18/4	1461	6	2025-11-04 22:09:15.110887	2025-11-05 08:29:07.619404	\N	\N	f	\N	t	4	f
1892	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/las-bolsas-se-adaptan-al-mundo-del-5-a-la-espera-de-jackson-hole	1463	6	2025-11-04 22:09:17.289206	2025-11-05 08:29:08.827542	\N	\N	f	\N	t	4	f
1893	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-3m-como-ejemplo-de-la-rotacion-en-base-a-los-resultados	1465	6	2025-11-04 22:09:18.553478	2025-11-05 08:29:10.080639	\N	\N	f	\N	t	4	f
1894	https://www.r4.com/articulos-y-analisis/ideas/claves-para-navegar-los-mercados-del-trump-2-0	1470	6	2025-11-04 22:09:19.820098	2025-11-05 08:29:12.3426	\N	\N	f	\N	t	4	f
1895	https://www.r4.com/articulos-y-analisis/ideas/impulsa-tu-cartera-invirtiendo-en-tendencias	1470	6	2025-11-04 22:09:22.636031	2025-11-05 08:29:13.555461	\N	\N	f	\N	t	4	f
1896	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=LU0274211480&MKT=MFR	1470	6	2025-11-04 22:09:23.872505	2025-11-05 08:29:14.804698	\N	\N	f	\N	t	4	f
1897	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=IE000YYE6WK5&MKT=MMI	1470	6	2025-11-04 22:09:25.054733	2025-11-05 08:29:15.956329	\N	\N	f	\N	t	4	f
1898	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=IE000NHAIBN0&MKT=MFR	1470	6	2025-11-04 22:09:26.261017	2025-11-05 08:29:17.087003	\N	\N	f	\N	t	4	f
1899	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU1654173217&DIVI=EUR&CBR=	1473	6	2025-11-04 22:09:27.487794	2025-11-05 08:29:18.277718	\N	\N	f	\N	t	4	f
1900	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU1295551144&DIVI=EUR&CBR=	1473	6	2025-11-04 22:09:28.695152	2025-11-05 08:29:19.496119	\N	\N	f	\N	t	4	f
1901	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=IE00B3XFBR64&DIVI=EUR&CBR=	1473	6	2025-11-04 22:09:29.952805	2025-11-05 08:29:20.681974	\N	\N	f	\N	t	4	f
1902	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU0329070915&DIVI=EUR&CBR=	1473	6	2025-11-04 22:09:31.200153	2025-11-05 08:29:21.866964	\N	\N	f	\N	t	4	f
1903	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU0329429897&DIVI=EUR&CBR=	1473	6	2025-11-04 22:09:32.415421	2025-11-05 08:29:23.025369	\N	\N	f	\N	t	4	f
1904	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU2466448532&DIVI=EUR&CBR=	1473	6	2025-11-04 22:09:33.621374	2025-11-05 08:29:24.227163	\N	\N	f	\N	t	4	f
1905	https://www.r4.com/portal?TX=goto&FWD=FCH_FND&PAG=5&HOJA=2&COD_ISIN=ES0173057011&DIVI=EUR	1474	6	2025-11-04 22:09:34.833331	2025-11-05 08:29:25.426902	\N	\N	f	\N	t	4	f
1906	https://www.r4.com/portal?TX=goto&FWD=FCH_FND&PAG=5&HOJA=2&COD_ISIN=ES0173130024&DIVI=EUR	1474	6	2025-11-04 22:09:36.01874	2025-11-05 08:29:26.585894	\N	\N	f	\N	t	4	f
1907	https://www.r4.com/portal?TX=goto&FWD=FCH_FND&PAG=5&HOJA=2&COD_ISIN=ES0173322001&DIVI=EUR	1475	6	2025-11-04 22:09:37.113627	2025-11-05 08:29:27.700408	\N	\N	f	\N	t	4	f
1908	https://www.r4.com/articulos-y-analisis/ideas/seleccion-50-fondos-para-las-grandes-tematicas-de-inversion	1477	6	2025-11-04 22:09:38.230618	2025-11-05 08:29:28.818692	\N	\N	f	\N	t	4	f
1909	https://www.r4.com/clientes/su-sesion-ha-caducado	1477	6	2025-11-04 22:09:39.769583	2025-11-05 08:29:30.051663	\N	\N	f	\N	t	4	f
1910	https://www.r4.com/articulos-y-analisis/ideas/seleccion-50-fondos-para-todos-los-perfiles	1477	6	2025-11-04 22:09:40.93526	2025-11-05 08:29:31.280996	\N	\N	f	\N	t	4	f
1911	https://www.r4.com/articulos-y-analisis/ideas/seleccion-50-una-oportunidad-de-inversion-para-todos	1477	6	2025-11-04 22:09:43.143497	2025-11-05 08:29:32.458042	\N	\N	f	\N	t	4	f
1912	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU0568621618&DIVI=USD&CBR=	1477	6	2025-11-04 22:09:44.33282	2025-11-05 08:29:34.896571	\N	\N	f	\N	t	4	f
1913	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU1533169378&DIVI=EUR&CBR=	1477	6	2025-11-04 22:09:45.529705	2025-11-05 08:29:36.088312	\N	\N	f	\N	t	4	f
1914	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=FR0007008750&DIVI=EUR&CBR=	1477	6	2025-11-04 22:09:46.733773	2025-11-05 08:29:37.347288	\N	\N	f	\N	t	4	f
1915	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU0970691076&DIVI=USD&CBR=	1477	6	2025-11-04 22:09:47.935455	2025-11-05 08:29:38.500236	\N	\N	f	\N	t	4	f
1916	https://www.r4.com/articulos-y-analisis/ideas/perspectivas-renta-fija-calma-senales-mixtas	1478	6	2025-11-04 22:09:49.133847	2025-11-05 08:29:39.732743	\N	\N	f	\N	t	4	f
1917	https://www.r4.com/articulos-y-analisis/ideas/el-cobre-metal-con-futuro-prometedor	1478	6	2025-11-04 22:09:51.573814	2025-11-05 08:29:40.95819	\N	\N	f	\N	t	4	f
1919	https://www.r4.com/articulos-y-analisis/ideas/revision-carteras-acciones-1S25	1478	6	2025-11-04 22:09:56.49739	2025-11-05 08:29:43.375154	\N	\N	f	\N	t	4	f
1920	https://www.r4.com/articulos-y-analisis/ideas/r4-seleccion-conservadora-en-2025	1478	6	2025-11-04 22:09:57.773809	2025-11-05 08:29:44.649347	\N	\N	f	\N	t	4	f
1921	https://www.r4.com/articulos-y-analisis/ideas/seleccion-30-etfs-para-cada-perfil-de-inversor	1478	6	2025-11-04 22:09:59.064577	2025-11-05 08:29:45.859255	\N	\N	f	\N	t	4	f
1922	https://www.r4.com/articulos-y-analisis/ideas/relajacion-tensiones-bce-finaliza-bajadas	1478	6	2025-11-04 22:10:00.349298	2025-11-05 08:29:47.079495	\N	\N	f	\N	t	4	f
1923	https://www.r4.com/articulos-y-analisis/ideas/por-que-invertir-en-baterias-almacenamiento	1478	6	2025-11-04 22:10:02.637223	2025-11-05 08:29:48.287827	\N	\N	f	\N	t	4	f
1924	https://www.r4.com/autor/beatriz-perez	1478	6	2025-11-04 22:10:04.903524	2025-11-05 08:29:49.530538	\N	\N	f	\N	t	4	f
1925	https://www.r4.com/articulos-y-analisis/ideas/acciona-sale-cartera-5-grandes-versatil	1478	6	2025-11-04 22:10:06.14633	2025-11-05 08:29:50.743322	\N	\N	f	\N	t	4	f
1926	https://www.r4.com/articulos-y-analisis/ideas/6	1478	6	2025-11-04 22:10:07.421952	2025-11-05 08:29:51.953987	\N	\N	f	\N	t	4	f
1933	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/ayudado-por-las-tecnologicas-trump-supera-su-primer-momento-de-la-verdad	1488	6	2025-11-04 22:10:19.540151	2025-11-05 08:30:00.63522	\N	\N	f	\N	t	4	f
1934	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/vuelta-al-punto-de-partida-pero-los-viejos-problemas-siguen-ahi	1488	6	2025-11-04 22:10:20.809927	2025-11-05 08:30:01.82936	\N	\N	f	\N	t	4	f
1935	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/culpar-a-powell-agravara-el-desconcierto-y-trump-deberia-entenderlo	1488	6	2025-11-04 22:10:23.225429	2025-11-05 08:30:03.032326	\N	\N	f	\N	t	4	f
1936	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/la-medicina-de-trump-y-sus-efectos-secundarios-un-problema-no-previsto	1488	6	2025-11-04 22:10:24.475836	2025-11-05 08:30:04.227081	\N	\N	f	\N	t	4	f
1929	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/un-magnifico-mayo-devuelve-al-s-p-a-los-6-000-puntos-pero-no-despeja-las-dudas	1488	6	2025-11-04 22:10:12.216468	2025-11-05 08:29:55.73516	\N	\N	f	\N	t	4	f
1930	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/trump-vuelve-a-la-guerra-comercial-mientras-los-bonos-y-el-dolar-acusan-la-beautiful-bill	1488	6	2025-11-04 22:10:13.451133	2025-11-05 08:29:56.990423	\N	\N	f	\N	t	4	f
1931	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/hay-desescalada-pero-ha-cambiado-trump-de-verdad-el-rumbo	1488	6	2025-11-04 22:10:15.84991	2025-11-05 08:29:58.204223	\N	\N	f	\N	t	4	f
1937	https://www.r4.com/columnas-de-autores/vive-la-pasion-de-los-mercados/4	1488	6	2025-11-04 22:10:26.808263	2025-11-05 08:30:05.48922	\N	\N	f	\N	t	4	f
1938	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-rheinmetall-y-kering-es-prudente-ser-defensivo	1489	6	2025-11-04 22:10:28.086749	2025-11-05 08:30:06.677041	\N	\N	f	\N	t	4	f
1939	https://www.r4.com/articulos-y-analisis/ideas/estrategia-inversion-2025	1491	6	2025-11-04 22:10:30.349546	2025-11-05 08:30:07.889103	\N	\N	f	\N	t	4	f
1940	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-la-fatiga-alcista-de-netflix-y-el-posible-suelo-de-lvmh	1495	6	2025-11-04 22:10:31.504045	2025-11-05 08:30:09.094142	\N	\N	f	\N	t	4	f
1941	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/en-japon-empieza-el-dia-y-las-turbulencias	1496	6	2025-11-04 22:10:33.727717	2025-11-05 08:30:11.38627	\N	\N	f	\N	t	4	f
1942	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/si-japon-tiene-el-252-de-deuda-por-que-preocuparse-por-el-120-de-estados-unidos	1496	6	2025-11-04 22:10:35.031025	2025-11-05 08:30:12.596876	\N	\N	f	\N	t	4	f
1943	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-trump-impulsa-el-bitcoin-y-el-cobre	1496	6	2025-11-04 22:10:36.275819	2025-11-05 08:30:13.809596	\N	\N	f	\N	t	4	f
1944	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/la-guerra-de-aranceles-es-solo-la-excusa	1496	6	2025-11-04 22:10:38.558267	2025-11-05 08:30:15.058745	\N	\N	f	\N	t	4	f
1945	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/energia-barata-y-abundante-es-la-clave	1496	6	2025-11-04 22:10:39.749604	2025-11-05 08:30:16.283934	\N	\N	f	\N	t	4	f
1946	https://www.r4.com/articulos-y-analisis/mercados/6	1496	6	2025-11-04 22:10:41.043319	2025-11-05 08:30:17.483018	\N	\N	f	\N	t	4	f
1947	https://www.r4.com/articulos-y-analisis/valores/puig-brands-previo-2s24-pendientes-de-los-margenes-para-cerrar-un-2024-historico	1506	6	2025-11-04 22:10:42.297753	2025-11-05 08:30:18.769946	\N	\N	f	\N	t	4	f
1948	https://www.r4.com/articulos-y-analisis/valores/puig-brands-avance-ventas-4t24-reacelerando-para-superar-estimaciones	1506	6	2025-11-04 22:10:44.525514	2025-11-05 08:30:19.956295	\N	\N	f	\N	t	4	f
1949	https://www.r4.com/articulos-y-analisis/valores/puig-brands-extiende-su-colaboracion-con-charlotte-tilbury	1506	6	2025-11-04 22:10:45.775954	2025-11-05 08:30:21.192064	\N	\N	f	\N	t	4	f
1950	https://www.r4.com/articulos-y-analisis/valores/puig-brands-regalate-un-perfume-por-navidad	1506	6	2025-11-04 22:10:46.997656	2025-11-05 08:30:22.41949	\N	\N	f	\N	t	4	f
1951	https://www.r4.com/articulos-y-analisis/valores/puig-brands-retira-un-producto-charlotte-tilbury	1506	6	2025-11-04 22:10:48.197291	2025-11-05 08:30:23.617469	\N	\N	f	\N	t	4	f
1952	https://www.r4.com/articulos-y-analisis/valores/puig-brands-inicio-de-cobertura-una-bonita-historia-contada-a-traves-del-olfato	1506	6	2025-11-04 22:10:49.441929	2025-11-05 08:30:24.868373	\N	\N	f	\N	t	4	f
1954	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105777017	1506	6	2025-11-04 22:10:52.03408	2025-11-05 08:30:27.272604	\N	\N	f	\N	t	4	f
1955	https://www.r4.com/articulos-y-analisis/valores/repsol-rotacion-activo-upstream-en-indonesia	1516	6	2025-11-04 22:10:54.124718	2025-11-05 08:30:28.511146	\N	\N	f	\N	t	4	f
1956	https://www.r4.com/articulos-y-analisis/valores/repsol-1t25-flexibilidad-ante-la-incertidumbre	1516	6	2025-11-04 22:10:56.408092	2025-11-05 08:30:29.693043	\N	\N	f	\N	t	4	f
1957	https://www.r4.com/articulos-y-analisis/valores/repsol-1t25-escenario-mas-negativo-pero-manteniendo-compromisos	1516	6	2025-11-04 22:10:57.628493	2025-11-05 08:30:30.880621	\N	\N	f	\N	t	4	f
1958	https://www.r4.com/articulos-y-analisis/valores/repsol-rotacion-activos-renovables-en-ee-uu	1516	6	2025-11-04 22:10:58.891918	2025-11-05 08:30:32.163976	\N	\N	f	\N	t	4	f
1959	https://www.r4.com/articulos-y-analisis/valores/repsol-previo-1t25-pendientes-de-la-guia-en-el-nuevo-contexto-de-precios	1516	6	2025-11-04 22:11:01.096369	2025-11-05 08:30:33.382549	\N	\N	f	\N	t	4	f
1960	https://www.r4.com/articulos-y-analisis/valores/repsol-trading-statement-del-1t2025	1516	6	2025-11-04 22:11:03.343693	2025-11-05 08:30:34.570891	\N	\N	f	\N	t	4	f
1961	https://www.r4.com/articulos-y-analisis/valores/repsol-ee-uu-le-retira-la-autorizacion-para-operar-en-venezuela	1516	6	2025-11-04 22:11:04.524394	2025-11-05 08:30:35.808538	\N	\N	f	\N	t	4	f
1962	https://www.r4.com/articulos-y-analisis/valores/repsol-fusion-del-negocio-en-uk-con-neo-energy-group	1516	6	2025-11-04 22:11:06.843007	2025-11-05 08:30:36.997962	\N	\N	f	\N	t	4	f
1963	https://www.r4.com/articulos-y-analisis/valores/repsol-rotacion-cartera-renovable	1516	6	2025-11-04 22:11:08.126298	2025-11-05 08:30:38.171908	\N	\N	f	\N	t	4	f
1964	https://www.r4.com/articulos-y-analisis/valores/repsol-adquisicion-40-unioil-filipinas	1516	6	2025-11-04 22:11:09.421656	2025-11-05 08:30:40.306827	\N	\N	f	\N	t	4	f
1965	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0173516115	1516	6	2025-11-04 22:11:11.86134	2025-11-05 08:30:42.568414	\N	\N	f	\N	t	4	f
1966	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0173516115/3	1516	6	2025-11-04 22:11:14.017383	2025-11-05 08:30:43.806687	\N	\N	f	\N	t	4	f
1967	https://www.r4.com/articulos-y-analisis/valores/acerinox-positivo-2024-gracias-a-nas-y-vdm	1528	6	2025-11-04 22:11:16.157478	2025-11-05 08:30:45.037537	\N	\N	f	\N	t	4	f
1968	https://www.r4.com/articulos-y-analisis/valores/acerinox-resultados-2023-mejor-de-lo-esperado-en-terminos-ajustados	1528	6	2025-11-04 22:11:17.433009	2025-11-05 08:30:46.265812	\N	\N	f	\N	t	4	f
1969	https://www.r4.com/articulos-y-analisis/valores/acerinox-previo-2023-otro-ano-por-encima-de-la-media	1528	6	2025-11-04 22:11:18.707578	2025-11-05 08:30:47.457931	\N	\N	f	\N	t	4	f
1970	https://www.r4.com/articulos-y-analisis/valores/acerinox-compra-de-haynes-international	1528	6	2025-11-04 22:11:19.940893	2025-11-05 08:30:48.681671	\N	\N	f	\N	t	4	f
1975	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-contrato-en-emiratos-arabes-unidos	1538	6	2025-11-04 22:11:27.534057	2025-11-05 08:30:57.02112	\N	\N	f	\N	t	4	f
1976	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-previo-4t24-confirmando-el-margen-ebit-del-4	1538	6	2025-11-04 22:11:28.804909	2025-11-05 08:30:58.217684	\N	\N	f	\N	t	4	f
1978	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-relanzamiento-del-contrato-en-argelia	1538	6	2025-11-04 22:11:31.377435	2025-11-05 08:31:00.600786	\N	\N	f	\N	t	4	f
1979	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-3t24-margen-ebit-en-el-4-2-por-primera-vez-desde-2015	1538	6	2025-11-04 22:11:32.622397	2025-11-05 08:31:01.870685	\N	\N	f	\N	t	4	f
1980	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-previo-3t24-margen-ebit-podria-superar-el-4-a-trimestre-estanco	1538	6	2025-11-04 22:11:33.876452	2025-11-05 08:31:03.090941	\N	\N	f	\N	t	4	f
1981	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-contrato-en-kazajistan	1538	6	2025-11-04 22:11:35.074253	2025-11-05 08:31:04.293971	\N	\N	f	\N	t	4	f
1982	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-2t24-mejor-en-terminos-absolutos-y-confirmando-los-margenes	1538	6	2025-11-04 22:11:36.249234	2025-11-05 08:31:05.530028	\N	\N	f	\N	t	4	f
1983	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0178165017	1538	6	2025-11-04 22:11:37.512201	2025-11-05 08:31:06.744993	\N	\N	f	\N	t	4	f
1984	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0178165017/3	1538	6	2025-11-04 22:11:38.800235	2025-11-05 08:31:07.946161	\N	\N	f	\N	t	4	f
1985	https://www.r4.com/articulos-y-analisis/valores/ebro-foods-1s24-buenos-resultados-record-en-linea-con-lo-esperado-no-descartamos-dividendo-extraordinario	1548	6	2025-11-04 22:11:40.84574	2025-11-05 08:31:09.123474	\N	\N	f	\N	t	4	f
1986	https://www.r4.com/articulos-y-analisis/valores/ebro-foods-previo-2t24-continuara-la-tendencia-positiva-no-descartamos-mejora-de-guidance	1548	6	2025-11-04 22:11:43.163272	2025-11-05 08:31:10.333519	\N	\N	f	\N	t	4	f
1988	https://www.r4.com/articulos-y-analisis/valores/ebro-foods-previo-1t24-mejora-continua	1548	6	2025-11-04 22:11:47.703141	2025-11-05 08:31:12.798757	\N	\N	f	\N	t	4	f
1989	https://www.r4.com/articulos-y-analisis/valores/ebro-foods-resultados-2023-record-historico-baten-al-guidance	1548	6	2025-11-04 22:11:48.924322	2025-11-05 08:31:14.028069	\N	\N	f	\N	t	4	f
1990	https://www.r4.com/articulos-y-analisis/valores/ebro-foods-previo-2023-no-descartamos-que-superen-al-guidance	1548	6	2025-11-04 22:11:51.162671	2025-11-05 08:31:15.227047	\N	\N	f	\N	t	4	f
1991	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0112501012	1548	6	2025-11-04 22:11:53.443439	2025-11-05 08:31:16.456691	\N	\N	f	\N	t	4	f
1992	https://www.r4.com/articulos-y-analisis/valores/tub-entrada-de-mubadala-en-el-negocio-de-octg	1560	6	2025-11-04 22:11:54.71145	2025-11-05 08:31:17.676407	\N	\N	f	\N	t	4	f
1993	https://www.r4.com/articulos-y-analisis/valores/tubacex-1t24-solidos-resultados-pero-por-debajo-de-lo-esperado	1560	6	2025-11-04 22:11:56.94039	2025-11-05 08:31:18.88001	\N	\N	f	\N	t	4	f
1994	https://www.r4.com/articulos-y-analisis/valores/tubacex-previo-1t24-retroceso-coyuntural	1560	6	2025-11-04 22:11:58.217417	2025-11-05 08:31:20.110986	\N	\N	f	\N	t	4	f
1995	https://www.r4.com/articulos-y-analisis/valores/tubacex-resultados-2023-record-historico-de-resultados	1560	6	2025-11-04 22:12:00.60326	2025-11-05 08:31:21.3605	\N	\N	f	\N	t	4	f
1996	https://www.r4.com/articulos-y-analisis/valores/tubacex-previo-2023-record-historico-de-resultados	1560	6	2025-11-04 22:12:02.972686	2025-11-05 08:31:22.551209	\N	\N	f	\N	t	4	f
1997	https://www.r4.com/articulos-y-analisis/valores/melia-hoteles-los-resultados-superan-nuestras-previsiones-y-mejor-evolucion-de-la-deuda-neta-perspectivas-favorables-para-2024e-si-bien-la-guia-ebitda-nos-parece-prudente	1572	6	2025-11-04 22:12:04.187229	2025-11-05 08:31:23.795499	\N	\N	f	\N	t	4	f
1998	https://www.r4.com/articulos-y-analisis/valores/melia-hoteles-previo-4t23-se-mantiene-la-fortaleza-de-la-demanda	1572	6	2025-11-04 22:12:06.358898	2025-11-05 08:31:24.993653	\N	\N	f	\N	t	4	f
1999	https://www.r4.com/articulos-y-analisis/valores/melia-entrevista-con-gabriel-escarrer-previa-al-comienzo-de-la-feria-fitur	1572	6	2025-11-04 22:12:07.590496	2025-11-05 08:31:26.255602	\N	\N	f	\N	t	4	f
2000	https://www.r4.com/articulos-y-analisis/valores/unicaja-resultados-4t23-recuperacion-de-la-nueva-produccion-anuncian-programa-de-recompra-de-acciones-sobreponderar-p-o-1-28-eur-acc	1584	6	2025-11-04 22:12:09.79339	2025-11-05 08:31:27.437757	\N	\N	f	\N	t	4	f
2001	https://www.r4.com/articulos-y-analisis/valores/sector-financiero-previo-4t23-ingresos-solidos-atentos-al-margen-de-intereses-2024	1584	6	2025-11-04 22:12:12.068419	2025-11-05 08:31:28.642462	\N	\N	f	\N	t	4	f
2002	https://www.r4.com/articulos-y-analisis/valores/caixabank-4t24-guias-2025-alineadas-con-el-plan-estrategico	1589	6	2025-11-04 22:12:14.268807	2025-11-05 08:31:29.870021	\N	\N	f	\N	t	4	f
2003	https://www.r4.com/articulos-y-analisis/valores/caixabank-emision-de-participaciones-preferentes-perpetuas-convertibles-cocos	1589	6	2025-11-04 22:12:15.453695	2025-11-05 08:31:31.095438	\N	\N	f	\N	t	4	f
2004	https://www.r4.com/articulos-y-analisis/valores/caixabank-ingresos-por-servicios-uno-de-los-soportes-del-rote	1589	6	2025-11-04 22:12:17.625529	2025-11-05 08:31:32.366601	\N	\N	f	\N	t	4	f
2005	https://www.r4.com/articulos-y-analisis/valores/caixabank-resultados-3t24-resiliencia-del-margen-de-intereses-nuevo-programa-de-recompra-de-acciones-sobreponderar-p-o-6-2-eur-acc	1589	6	2025-11-04 22:12:19.799239	2025-11-05 08:31:33.590484	\N	\N	f	\N	t	4	f
2006	https://www.r4.com/articulos-y-analisis/valores/caixabank-resultados-2t24-mejoran-guia-de-margen-de-intereses-rote-y-ratio-de-morosidad-sobreponderar-p-o-6-32-eur-acc	1589	6	2025-11-04 22:12:21.032089	2025-11-05 08:31:34.801688	\N	\N	f	\N	t	4	f
2007	https://www.r4.com/articulos-y-analisis/valores/caixabank-anuncia-un-nuevo-programa-de-recompra-de-acciones	1589	6	2025-11-04 22:12:23.214892	2025-11-05 08:31:35.994816	\N	\N	f	\N	t	4	f
2008	https://www.r4.com/articulos-y-analisis/valores/caixabank-estabilidad-de-ingresos-a-futuro-como-sena-de-identidad	1589	6	2025-11-04 22:12:24.49339	2025-11-05 08:31:37.194825	\N	\N	f	\N	t	4	f
2009	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0140609019	1589	6	2025-11-04 22:12:26.872691	2025-11-05 08:31:38.416502	\N	\N	f	\N	t	4	f
2010	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0140609019/3	1589	6	2025-11-04 22:12:28.939685	2025-11-05 08:31:40.537748	\N	\N	f	\N	t	4	f
2011	https://www.r4.com/articulos-y-analisis/valores/banco-santander-diversificacion-de-negocio-para-afianzar-el-crecimiento	1596	6	2025-11-04 22:12:30.951716	2025-11-05 08:31:42.811687	\N	\N	f	\N	t	4	f
42	https://www.r4.com/portal?TX=goto&FWD=BLS005&EXC=IBEX&PAG=1&HOJA=2&CAB2=1-1&INDX=1	2	1	2025-11-04 21:21:30.154735	2025-11-05 07:42:23.06837	\N	\N	f	\N	t	4	f
2013	https://www.r4.com/articulos-y-analisis/valores/conclusiones-conferencia-santander-4t24-resiliencia-de-los-ingresos-en-un-entorno-incierto	1596	6	2025-11-04 22:12:34.495317	2025-11-05 08:31:46.256703	\N	\N	f	\N	t	4	f
2016	https://www.r4.com/articulos-y-analisis/valores/santander-resultados-3t24-guias-del-ano-cumplidas-y-sin-cambios-sobreponderar-p-o-5-6-eur-acc	1596	6	2025-11-04 22:12:39.137977	2025-11-05 08:31:50.863013	\N	\N	f	\N	t	4	f
2017	https://www.r4.com/articulos-y-analisis/valores/santander-resultados-2t24-mejora-guias-de-ingresos-ratio-de-eficiencia-y-rote-sobreponderar-p-o-5-6-eur-acc	1596	6	2025-11-04 22:12:41.308269	2025-11-05 08:31:53.129741	\N	\N	f	\N	t	4	f
2018	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0113900J37	1596	6	2025-11-04 22:12:42.65585	2025-11-05 08:31:55.262352	\N	\N	f	\N	t	4	f
2019	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0113900J37/3	1596	6	2025-11-04 22:12:44.738283	2025-11-05 08:31:56.407214	\N	\N	f	\N	t	4	f
2021	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0165386014	1605	6	2025-11-04 22:12:49.036828	2025-11-05 08:31:59.728632	\N	\N	f	\N	t	4	f
2022	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0105287009	1608	6	2025-11-04 22:12:50.288919	2025-11-05 08:32:01.975147	\N	\N	f	\N	t	4	f
2023	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0105251005	1608	6	2025-11-04 22:12:51.537207	2025-11-05 08:32:04.135885	\N	\N	f	\N	t	4	f
2024	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0105287009&MKT=MCO	1608	6	2025-11-04 22:12:53.655307	2025-11-05 08:32:06.165332	\N	\N	f	\N	t	4	f
2025	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0154653911&MKT=MCO	1608	6	2025-11-04 22:12:54.869444	2025-11-05 08:32:07.344224	\N	\N	f	\N	t	4	f
2026	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0105122024&MKT=MCO	1608	6	2025-11-04 22:12:56.058441	2025-11-05 08:32:08.593327	\N	\N	f	\N	t	4	f
2027	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0105251005&MKT=MCO	1608	6	2025-11-04 22:12:57.233279	2025-11-05 08:32:09.795904	\N	\N	f	\N	t	4	f
2028	https://www.r4.com/articulos-y-analisis/informes-de-analisis/los-aranceles-reciprocos-podrian-ser-menos-agresivos	1613	6	2025-11-04 22:12:58.424917	2025-11-05 08:32:11.01256	\N	\N	f	\N	t	4	f
2029	https://www.r4.com/articulos-y-analisis/valores/promotoras-el-precio-de-la-vivienda-subira-un-10-en-compraventa-y-un-8-6-en-alquiler-en-2025-segun-uci-y-sira	1614	6	2025-11-04 22:12:59.703248	2025-11-05 08:32:13.604305	\N	\N	f	\N	t	4	f
2030	https://www.r4.com/articulos-y-analisis/valores/inmobiliaria-del-sur-4t24-2024-gran-cierre-de-ano-con-positiva-sorpresa-en-dividendo	1614	6	2025-11-04 22:13:02.046833	2025-11-05 08:32:14.82398	\N	\N	f	\N	t	4	f
2031	https://www.r4.com/articulos-y-analisis/valores/inmobiliaria-del-sur-previo-4t24-un-buen-ano	1614	6	2025-11-04 22:13:03.268909	2025-11-05 08:32:15.990356	\N	\N	f	\N	t	4	f
2032	https://www.r4.com/articulos-y-analisis/valores/inmobiliaria-del-sur-cada-vez-quedan-menos-joyas-inmobiliarias-cotizadas-y-a-buen-precio	1614	6	2025-11-04 22:13:05.537526	2025-11-05 08:32:18.103197	\N	\N	f	\N	t	4	f
2033	https://www.r4.com/articulos-y-analisis/valores/inmobiliaria-del-sur-3t24-9m24-buena-tendencia-anticipando-un-mejor-4t24	1614	6	2025-11-04 22:13:07.708855	2025-11-05 08:32:20.568413	\N	\N	f	\N	t	4	f
2034	https://www.r4.com/articulos-y-analisis/valores/inmobiliaria-del-sur-previo-3t24-buena-actividad-comercial-anticipa-un-solido-2024	1614	6	2025-11-04 22:13:08.87442	2025-11-05 08:32:22.711837	\N	\N	f	\N	t	4	f
2035	https://www.r4.com/articulos-y-analisis/valores/inmobiliaria-del-sur-2t24-1s24-muy-buenos-resultados	1614	6	2025-11-04 22:13:10.056169	2025-11-05 08:32:24.87136	\N	\N	f	\N	t	4	f
2036	https://www.r4.com/articulos-y-analisis/valores/promotoras-el-principal-riesgo-del-sector-es-perderselo	1614	6	2025-11-04 22:13:12.349236	2025-11-05 08:32:26.002859	\N	\N	f	\N	t	4	f
2037	https://www.r4.com/articulos-y-analisis/valores/inmobiliaria-del-sur-1t24-fuerte-inicio-de-ano-en-linea-con-lo-esperado	1614	6	2025-11-04 22:13:13.56834	2025-11-05 08:32:28.444877	\N	\N	f	\N	t	4	f
2038	https://www.r4.com/articulos-y-analisis/valores/inmobiliaria-del-sur-previo-1t24-fuerte-comienzo-operativo	1614	6	2025-11-04 22:13:15.83207	2025-11-05 08:32:29.631559	\N	\N	f	\N	t	4	f
2039	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0154653911	1614	6	2025-11-04 22:13:18.031572	2025-11-05 08:32:32.032036	\N	\N	f	\N	t	4	f
2040	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0154653911/3	1614	6	2025-11-04 22:13:20.277112	2025-11-05 08:32:34.190765	\N	\N	f	\N	t	4	f
2042	https://www.r4.com/articulos-y-analisis/valores/vidrala-procede-a-la-venta-de-su-filial-italiana-por-230-millones-de-euros	1624	6	2025-11-04 22:13:22.806302	2025-11-05 08:32:36.727497	\N	\N	f	\N	t	4	f
2043	https://www.r4.com/articulos-y-analisis/valores/vidrala-pre-4t23-ano-record-en-resultados-y-nuevo-asalto-al-crecimiento-inorganico	1624	6	2025-11-04 22:13:25.170257	2025-11-05 08:32:37.922183	\N	\N	f	\N	t	4	f
2044	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0183746314	1624	6	2025-11-04 22:13:26.392209	2025-11-05 08:32:39.111883	\N	\N	f	\N	t	4	f
2045	https://www.r4.com/articulos-y-analisis/valores/ence-4t24-2024-resultados-en-linea-y-con-buenas-perspectivas-para-2025-por-recuperacion-en-precios-de-la-pulpa-los-nuevos-negocios-ganan-visibilidad	1634	6	2025-11-04 22:13:27.713798	2025-11-05 08:32:40.417002	\N	\N	f	\N	t	4	f
2046	https://www.r4.com/articulos-y-analisis/valores/ence-previo-4t24-buen-2024-pese-al-debil-4t	1634	6	2025-11-04 22:13:28.984929	2025-11-05 08:32:41.670812	\N	\N	f	\N	t	4	f
2047	https://www.r4.com/articulos-y-analisis/valores/ence-convocada-24h-de-huelga-en-pontevedra	1634	6	2025-11-04 22:13:30.280332	2025-11-05 08:32:42.897898	\N	\N	f	\N	t	4	f
2048	https://www.r4.com/articulos-y-analisis/valores/ence-adquiere-su-primera-planta-de-biometano	1634	6	2025-11-04 22:13:31.572043	2025-11-05 08:32:44.128659	\N	\N	f	\N	t	4	f
2049	https://www.r4.com/articulos-y-analisis/valores/ence-3t24-optimistas-pese-a-que-el-4t24-y-1t25-seran-algo-mas-debiles	1634	6	2025-11-04 22:13:32.861351	2025-11-05 08:32:45.333837	\N	\N	f	\N	t	4	f
2050	https://www.r4.com/articulos-y-analisis/valores/ence-3t24-el-buen-entorno-de-mercado-permite-generar-caja-y-repartir-dividendo	1634	6	2025-11-04 22:13:34.083702	2025-11-05 08:32:46.590232	\N	\N	f	\N	t	4	f
2051	https://www.r4.com/articulos-y-analisis/valores/ence-previo-3t24-buen-entorno-de-mercado-impactado-por-un-cash-cost-elevado	1634	6	2025-11-04 22:13:35.316821	2025-11-05 08:32:47.783171	\N	\N	f	\N	t	4	f
2052	https://www.r4.com/articulos-y-analisis/valores/ence-el-constitucional-inadmite-el-recurso-de-la-abogacia-del-estado	1634	6	2025-11-04 22:13:36.519528	2025-11-05 08:32:48.97165	\N	\N	f	\N	t	4	f
2053	https://www.r4.com/articulos-y-analisis/valores/ence-2t24-ante-el-dilema-de-la-asignacion-del-capital-inversion-remuneracion-y-balance	1634	6	2025-11-04 22:13:38.743569	2025-11-05 08:32:50.164485	\N	\N	f	\N	t	4	f
2054	https://www.r4.com/articulos-y-analisis/valores/ence-2t24-elevados-precios-y-reduccion-de-costes-para-generar-caja-y-pagar-dividendo	1634	6	2025-11-04 22:13:40.002444	2025-11-05 08:32:51.394681	\N	\N	f	\N	t	4	f
2055	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0130625512	1634	6	2025-11-04 22:13:41.193596	2025-11-05 08:32:52.627115	\N	\N	f	\N	t	4	f
2056	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0130625512/3	1634	6	2025-11-04 22:13:43.177608	2025-11-05 08:32:53.84942	\N	\N	f	\N	t	4	f
2057	https://www.r4.com/articulos-y-analisis/valores/indra-estudia-integrar-escribano-mechanical-engineering-em-e-group	1644	6	2025-11-04 22:13:45.298772	2025-11-05 08:32:55.045401	\N	\N	f	\N	t	4	f
21	https://www.r4.com/fondos-de-inversion/categorias	2	1	2025-11-04 21:20:58.851066	2025-11-05 07:41:56.344979	\N	\N	f	\N	t	4	f
54	https://www.r4.com/portal?TX=goto&FWD=BUSCADOR_ETF_AVANZADO&PORTLET=BUSC_FND_AVZ&PAG=2&SUB_HOJ=3	2	1	2025-11-04 21:21:44.213565	2025-11-05 07:42:37.047826	\N	\N	f	\N	t	4	f
60	https://www.r4.com/portal?TX=goto&FWD=BUSC_DERIV&PAG=8	2	1	2025-11-04 21:21:51.025411	2025-11-05 07:42:43.680784	\N	\N	f	\N	t	4	f
67	https://www.r4.com/portal?TX=warrants&OPC=4&TIPO=IND&PAG=8&HOJA=3	2	1	2025-11-04 21:21:58.889153	2025-11-05 07:42:51.591732	\N	\N	f	\N	t	4	f
91	https://www.r4.com/portal?TX=goto&FWD=CONT_LND&PAG=0	2	1	2025-11-04 21:22:27.369178	2025-11-05 07:43:20.329527	\N	\N	f	\N	t	4	f
102	https://www.r4.com/que-necesitas/especialista-inversion	2	1	2025-11-04 21:22:40.888875	2025-11-05 07:43:33.70592	\N	\N	f	\N	t	4	f
123	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=AGS&TIPOCARTERA=1&CARTERA=DIV	16	2	2025-11-04 21:23:07.204222	2025-11-05 07:43:58.682162	\N	\N	f	\N	t	4	f
128	https://www.r4.com/articulos-y-analisis/valores/inditex-resultados-1t-25-incumplen-previsiones-a-nivel-operativo-inicio-de-ventas-2t-25-levemente-por-debajo-de-nuestra-prevision-mayor-impacto-negativo-de-la-divisa-previsto-para-2025e	16	2	2025-11-04 21:23:13.216107	2025-11-05 07:44:05.93381	\N	\N	f	\N	t	4	f
163	https://www.r4.com/fondos-de-inversion/fondos/ES0173322001	22	2	2025-11-04 21:24:00.763213	2025-11-05 07:44:53.617604	\N	\N	f	\N	t	4	f
181	https://www.r4.com/fondos-de-inversion/fondos/ES0128520006	24	2	2025-11-04 21:24:24.004126	2025-11-05 07:45:15.834	\N	\N	f	\N	t	4	f
2060	https://www.r4.com/articulos-y-analisis/valores/indra-previo-4t-24-prosigue-su-favorable-evolucion-la-venta-de-activos-y-la-renovacion-del-consejo-en-el-punto-de-mira	1644	6	2025-11-04 22:13:50.213681	2025-11-05 08:32:59.719676	\N	\N	f	\N	t	4	f
2061	https://www.r4.com/articulos-y-analisis/valores/indra-conferencia-adquisicion-hispasat	1644	6	2025-11-04 22:13:51.359346	2025-11-05 08:33:00.939474	\N	\N	f	\N	t	4	f
2062	https://www.r4.com/articulos-y-analisis/valores/indra-ha-firmado-un-acuerdo-con-redeia-para-comprar-su-participacion-en-hispasat	1644	6	2025-11-04 22:13:52.535444	2025-11-05 08:33:03.119257	\N	\N	f	\N	t	4	f
2063	https://www.r4.com/articulos-y-analisis/valores/indra-el-consejo-de-administracion-nombra-a-d-angel-escribano-ruiz-presidente-ejecutivo-y-consejero-del-grupo	1644	6	2025-11-04 22:13:54.746093	2025-11-05 08:33:05.346771	\N	\N	f	\N	t	4	f
2064	https://www.r4.com/articulos-y-analisis/valores/indra-mayor-foco-en-defensa-y-en-operaciones-corporativas	1644	6	2025-11-04 22:13:57.080054	2025-11-05 08:33:06.553581	\N	\N	f	\N	t	4	f
2065	https://www.r4.com/articulos-y-analisis/valores/indra-evolucion-sector-defensa-en-espana-2023	1644	6	2025-11-04 22:13:58.392931	2025-11-05 08:33:07.790017	\N	\N	f	\N	t	4	f
2066	https://www.r4.com/articulos-y-analisis/valores/indra-resultados-3t-24-que-superan-ampliamente-en-resultado-operativo-mantienen-la-guia-2024e-tras-haberla-mejorado-en-julio-p-o-24-2-eur-sobreponderar	1644	6	2025-11-04 22:13:59.607939	2025-11-05 08:33:08.980262	\N	\N	f	\N	t	4	f
2067	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0118594417	1644	6	2025-11-04 22:14:00.769947	2025-11-05 08:33:10.20812	\N	\N	f	\N	t	4	f
2068	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0118594417/3	1644	6	2025-11-04 22:14:01.935547	2025-11-05 08:33:11.420841	\N	\N	f	\N	t	4	f
2069	https://www.r4.com/articulos-y-analisis/valores/linea-directa-resultados-9m25-la-siniestralidad-pasa-factura-al-trimestre-mantener-p-o-1-48-eur-acc	1647	6	2025-11-04 22:14:03.952112	2025-11-05 08:33:12.695491	\N	\N	f	\N	t	4	f
2070	https://www.r4.com/articulos-y-analisis/valores/navigator-3t25-estrategia-acertada-en-entorno-adverso	1647	6	2025-11-04 22:14:05.182054	2025-11-05 08:33:15.040561	\N	\N	f	\N	t	4	f
2071	https://www.r4.com/articulos-y-analisis/valores/iberdrola-previo-9m25-sin-grandes-novedades-previstas-tras-cmd-de-septiembre	1647	6	2025-11-04 22:14:07.414586	2025-11-05 08:33:16.219384	\N	\N	f	\N	t	4	f
2072	https://www.r4.com/articulos-y-analisis/valores/6	1647	6	2025-11-04 22:14:09.602641	2025-11-05 08:33:18.348292	\N	\N	f	\N	t	4	f
2073	https://www.r4.com/articulos-y-analisis/valores/gestamp-4t23-cierta-decepcion-de-las-cifras-y-de-las-guias-para-2024	1658	6	2025-11-04 22:14:10.820932	2025-11-05 08:33:20.498257	\N	\N	f	\N	t	4	f
2074	https://www.r4.com/articulos-y-analisis/valores/gestamp-pre-4t23-se-desinfla-en-la-segunda-mitad-aunque-alcanza-los-objetivos	1658	6	2025-11-04 22:14:12.906906	2025-11-05 08:33:21.68618	\N	\N	f	\N	t	4	f
2075	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105223004	1658	6	2025-11-04 22:14:15.112187	2025-11-05 08:33:23.984723	\N	\N	f	\N	t	4	f
2077	https://www.r4.com/articulos-y-analisis/tecnico/moncler-completa-una-pauta-alcista-y-ademas-activa-una-senal-de-compra	1669	6	2025-11-04 22:14:17.635636	2025-11-05 08:33:27.344738	\N	\N	f	\N	t	4	f
2078	https://www.r4.com/articulos-y-analisis/tecnico/eurodolar-sugiere-aun-mas-debilidad-para-el-dolar	1669	6	2025-11-04 22:14:19.844927	2025-11-05 08:33:29.687591	\N	\N	f	\N	t	4	f
2079	https://www.r4.com/articulos-y-analisis/tecnico/asml-completa-un-cambio-de-tendencia-en-teoria-le-queda-un-36	1669	6	2025-11-04 22:14:22.132465	2025-11-05 08:33:32.066545	\N	\N	f	\N	t	4	f
2080	https://www.r4.com/articulos-y-analisis/tecnico/fluidra-fluye-en-tendencia	1669	6	2025-11-04 22:14:23.315221	2025-11-05 08:33:33.215526	\N	\N	f	\N	t	4	f
2081	https://www.r4.com/articulos-y-analisis/tecnico/los-semiconductores-rompen-maximos-e-historicamente-ha-venido-precediendo-mas-subidas-en-los-siguientes-meses	1669	6	2025-11-04 22:14:25.90917	2025-11-05 08:33:34.361469	\N	\N	f	\N	t	4	f
2082	https://www.r4.com/articulos-y-analisis/tecnico/grifols-asi-si	1669	6	2025-11-04 22:14:28.15192	2025-11-05 08:33:35.52946	\N	\N	f	\N	t	4	f
2083	https://www.r4.com/articulos-y-analisis/tecnico/grupo-san-jose-solida-tendencia-alcista-y-mejor-que-su-indice-de-referencia	1669	6	2025-11-04 22:14:29.354887	2025-11-05 08:33:37.772782	\N	\N	f	\N	t	4	f
2084	https://www.r4.com/articulos-y-analisis/tecnico/sabadell-el-unico-banco-espanol-por-debajo-de-los-maximos-de-2007	1669	6	2025-11-04 22:14:30.553578	2025-11-05 08:33:38.962965	\N	\N	f	\N	t	4	f
2085	https://www.r4.com/articulos-y-analisis/tecnico/6	1669	6	2025-11-04 22:14:31.705055	2025-11-05 08:33:40.127432	\N	\N	f	\N	t	4	f
2086	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-small-caps-global-a-cierre-de-julio-de-2025	1680	6	2025-11-04 22:14:32.878819	2025-11-05 08:33:42.283025	\N	\N	f	\N	t	4	f
193	https://www.r4.com/fondos-de-inversion/fondos/ES0168992008	26	2	2025-11-04 21:24:39.127595	2025-11-05 07:45:30.796797	\N	\N	f	\N	t	4	f
204	https://www.r4.com/portal?TX=goto&FWD=FCH_FND&PAG=5&HOJA=2&COD_ISIN=ES0173270010&DIVI=EUR	28	2	2025-11-04 21:24:53.608093	2025-11-05 07:45:44.385739	\N	\N	f	\N	t	4	f
219	https://www.r4.com/fondos-de-inversion/fondos/LU1914597502	30	2	2025-11-04 21:25:11.763475	2025-11-05 07:46:04.733154	\N	\N	f	\N	t	4	f
231	https://www.r4.com/fondos-de-inversion/fondos/LU0348784041	30	2	2025-11-04 21:25:27.044413	2025-11-05 07:46:21.824438	\N	\N	f	\N	t	4	f
232	https://www.r4.com/fondos-de-inversion/fondos/LU0329070915	30	2	2025-11-04 21:25:28.386208	2025-11-05 07:46:23.005202	\N	\N	f	\N	t	4	f
238	https://www.r4.com/fondos-de-inversion/fondos/LU0203975437	30	2	2025-11-04 21:25:38.871613	2025-11-05 07:46:30.397713	\N	\N	f	\N	t	4	f
249	https://www.r4.com/fondos-de-inversion/fondos/LU2466448532	30	2	2025-11-04 21:26:00.256333	2025-11-05 07:46:45.526108	\N	\N	f	\N	t	4	f
262	https://www.r4.com/planes-de-pensiones/planes/EP1	31	2	2025-11-04 21:26:23.294607	2025-11-05 07:47:04.958357	\N	\N	f	\N	t	4	f
306	https://www.r4.com/articulos-y-analisis/valores/telefonica-dia-del-inversor-guia-hasta-2028e-y-2030e	34	2	2025-11-04 21:27:26.842354	2025-11-05 07:47:59.699308	\N	\N	f	\N	t	4	f
322	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=XS2434891219&MKT=MFR	35	2	2025-11-04 21:27:45.103898	2025-11-05 07:48:18.686779	\N	\N	f	\N	t	4	f
345	https://www.r4.com/goto/contactar	41	2	2025-11-04 21:28:12.256747	2025-11-05 07:48:47.953501	\N	\N	f	\N	t	4	f
348	https://www.r4.com/goto/iniciar/sesion	41	2	2025-11-04 21:28:16.176875	2025-11-05 07:48:52.084033	\N	\N	f	\N	t	4	f
357	https://www.r4.com/go/derivados/futuros-sobre-materias-primas	46	2	2025-11-04 21:28:28.029657	2025-11-05 07:49:03.934706	\N	\N	f	\N	t	4	f
370	https://www.r4.com/broker-online/productos-de-inversion/renta-fija	69	2	2025-11-04 21:28:44.098918	2025-11-05 07:49:20.089524	\N	\N	f	\N	t	4	f
380	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=ES0173270010&DIVI=EUR&CBR=	82	2	2025-11-04 21:28:56.534921	2025-11-05 07:49:32.685915	\N	\N	f	\N	t	4	f
387	https://www.r4.com/articulos-y-analisis/informes-de-analisis/el-ibex-vuelve-a-maximos-tras-18-anos-continuamos-pendientes-de-resultados-empresariales-y-limitados-datos-macro-en-ee-uu	84	2	2025-11-04 21:29:05.429729	2025-11-05 07:49:41.054035	\N	\N	f	\N	t	4	f
401	https://www.r4.com/articulos-y-analisis/ideas/mesa-expertos-iv	85	2	2025-11-04 21:29:22.581146	2025-11-05 07:49:58.034357	\N	\N	f	\N	t	4	f
402	https://www.r4.com/articulos-y-analisis/ideas/el-tridente-europeo-de-equipos-de-semiconductores	85	2	2025-11-04 21:29:23.819781	2025-11-05 07:49:59.222501	\N	\N	f	\N	t	4	f
412	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/las-bolsas-superan-multiples-retos-pero-emiten-algunas-senales-de-alerta	86	2	2025-11-04 21:29:39.530728	2025-11-05 07:50:12.450164	\N	\N	f	\N	t	4	f
432	https://www.r4.com/articulos-y-analisis/tecnico/eurodolar-mantiene-una-consolidacion-con-una-configuracion-alcista	88	2	2025-11-04 21:30:10.563429	2025-11-05 07:50:40.994233	\N	\N	f	\N	t	4	f
448	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-alpha-global-a-cierre-de-septiembre-de-2025	89	2	2025-11-04 21:30:32.909749	2025-11-05 07:51:04.539135	\N	\N	f	\N	t	4	f
450	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-latinoamerica-a-cierre-de-septiembre-de-2025	89	2	2025-11-04 21:30:37.679775	2025-11-05 07:51:06.939069	\N	\N	f	\N	t	4	f
453	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-renta-fija-mixto-a-cierre-de-septiembre-de-2025	89	2	2025-11-04 21:30:42.415892	2025-11-05 07:51:12.519444	\N	\N	f	\N	t	4	f
555	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0105884011	134	3	2025-11-04 21:33:15.382093	2025-11-05 07:53:40.246856	\N	\N	f	\N	t	4	f
597	https://r4.com/normativa/tablon-de-anuncios	301	3	2025-11-04 21:34:14.502649	2025-11-05 07:54:33.607382	\N	\N	f	\N	t	4	f
612	https://www.r4.com/articulos-y-analisis/informes-de-analisis/macro-resultados-y-tribunal-supremo-sobre-legalidad-de-aranceles-reciprocos-marcaran-la-semana	385	3	2025-11-04 21:34:33.325438	2025-11-05 07:54:53.132698	\N	\N	f	\N	t	4	f
614	https://www.r4.com/articulos-y-analisis/informes-de-analisis/ee-uu-china-acercan-posturas-pero-no-es-un-12-10-fed-cuestiona-recorte-de-tipos-en-diciembre-hoy-bce-y-bateria-de-resultados	385	3	2025-11-04 21:34:35.743031	2025-11-05 07:54:55.439254	\N	\N	f	\N	t	4	f
645	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US5949181045&MKT=MMO	400	3	2025-11-04 21:35:12.857444	2025-11-05 07:55:38.180568	\N	\N	f	\N	t	4	f
658	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=NL0012866412&MKT=MAS	402	3	2025-11-04 21:35:29.085595	2025-11-05 07:55:54.524529	\N	\N	f	\N	t	4	f
659	https://www.r4.com/articulos-y-analisis/ideas/arcelor-sacyr-entran-en-cartera	403	3	2025-11-04 21:35:30.246735	2025-11-05 07:55:55.724392	\N	\N	f	\N	t	4	f
670	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/las-bolsas-no-necesitan-noticias-para-subir-o-tal-vez-si	404	3	2025-11-04 21:35:44.705305	2025-11-05 07:56:09.098127	\N	\N	f	\N	t	4	f
685	https://www.r4.com/articulos-y-analisis/valores/dia-avance-ventas-3t25-superan-estimaciones-tanto-en-espana-como-en-argentina-buena-ejecucion-del-pe-25-29	418	3	2025-11-04 21:36:07.850223	2025-11-05 07:56:29.840497	\N	\N	f	\N	t	4	f
707	https://www.r4.com/articulos-y-analisis/tecnico/estrategia-rupturas-trimestrales-actualizacion-febrero-2025-entra-cisco	430	3	2025-11-04 21:36:46.431432	2025-11-05 07:57:03.654385	\N	\N	f	\N	t	4	f
725	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/renta-4-renta-fija-mixto-diversificar-en-calidad-con-un-fondo-mixto-moderado	451	3	2025-11-04 21:37:15.499084	2025-11-05 07:57:33.04045	\N	\N	f	\N	t	4	f
741	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-eeuu-acciones-fi-a-cierre-de-septiembre-de-2025	458	3	2025-11-04 21:37:36.673775	2025-11-05 07:57:57.317416	\N	\N	f	\N	t	4	f
747	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-nexus-a-cierre-de-agosto-de-2025	458	3	2025-11-04 21:37:46.004676	2025-11-05 07:58:08.852788	\N	\N	f	\N	t	4	f
750	https://www.r4.com/articulos-y-analisis/cripto/bitcoin-geopolitica-capital-institucional-nuevo-mercado	468	3	2025-11-04 21:37:49.632906	2025-11-05 07:58:14.39348	\N	\N	f	\N	t	4	f
769	https://www.r4.com/academiar4/formulario-cursos?id=4378	489	3	2025-11-04 21:38:19.188534	2025-11-05 07:58:51.982442	\N	\N	f	\N	t	4	f
789	https://www.r4.com/inversion-para-todos/mercados-financieros-que-son-como-funcionan-y-que-tipos-existen	507	3	2025-11-04 21:38:51.894495	2025-11-05 07:59:23.067998	\N	\N	f	\N	t	4	f
800	https://www.r4.com/inversion-para-todos/diferencia-entre-warrants-y-opciones	507	3	2025-11-04 21:39:10.273703	2025-11-05 07:59:40.632489	\N	\N	f	\N	t	4	f
805	https://www.r4.com/inversion-para-todos/invertir-en-private-equity-que-es-y-estrategias-para-invertir	508	3	2025-11-04 21:39:18.096863	2025-11-05 07:59:49.449299	\N	\N	f	\N	t	4	f
821	https://www.r4.com/inversion-para-todos/category/invertir-tus-ahorros/page/2	508	3	2025-11-04 21:39:43.275152	2025-11-05 08:00:18.003472	\N	\N	f	\N	t	4	f
835	https://www.r4.com/inversion-para-todos/como-ahorrar-vacaciones-verano	509	3	2025-11-04 21:40:05.58616	2025-11-05 08:00:43.850721	\N	\N	f	\N	t	4	f
848	https://www.r4.com/inversion-para-todos/tipos-de-riesgo-en-inversiones-financieras	510	3	2025-11-04 21:40:25.943475	2025-11-05 08:01:06.21925	\N	\N	f	\N	t	4	f
853	https://www.r4.com/inversion-para-todos/invertir-en-fondos-indexados	511	3	2025-11-04 21:40:33.293174	2025-11-05 08:01:14.267002	\N	\N	f	\N	t	4	f
856	https://www.r4.com/inversion-para-todos/fiscalidad-y-tributacion-de-los-bonos-y-obligaciones-del-estado	514	3	2025-11-04 21:40:38.145265	2025-11-05 08:01:19.563431	\N	\N	f	\N	t	4	f
873	https://www.r4.com/inversion-para-todos/guia-sobre-como-invertir-en-oro	519	3	2025-11-04 21:41:05.261096	2025-11-05 08:01:49.24831	\N	\N	f	\N	t	4	f
293	https://www.r4.com/quienes-somos	32	2	2025-11-04 21:27:10.707438	2025-11-05 07:47:44.291931	\N	\N	f	\N	t	4	t
877	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-banco-obtiene-un-beneficio-neto-de-19-4-millones-de-euros-en-el-primer-semestre-de-2025-un-26-7-mas-que-en-el-mismo-periodo-de-2024	532	3	2025-11-04 21:41:10.781903	2025-11-05 08:01:56.311655	\N	\N	f	\N	t	4	f
905	https://www.r4.com/articulos-y-analisis/valores/bbva-retira-la-oferta-por-sabadell-al-no-alcanzar-el-nivel-minimo-de-aceptacion	544	4	2025-11-04 21:41:46.94483	2025-11-05 08:02:38.799276	\N	\N	f	\N	t	4	f
913	https://www.r4.com/articulos-y-analisis/valores/enagas-9m25-alineados-para-alcanzar-guia	545	4	2025-11-04 21:41:58.186935	2025-11-05 08:02:48.62787	\N	\N	f	\N	t	4	f
923	https://www.r4.com/articulos-y-analisis/valores/naturgy-9m25-beneficio-neto-por-encima-de-las-previsiones-revisan-guia-de-deuda-neta-por-colocaciones	546	4	2025-11-04 21:42:16.232656	2025-11-05 08:03:00.705777	\N	\N	f	\N	t	4	f
943	https://www.r4.com/articulos-y-analisis/valores/ferrovial-2024-la-posicion-de-caja-neta-mejora-por-encima-de-lo-previsto-por-el-flujo-operativo	548	4	2025-11-04 21:42:47.298551	2025-11-05 08:03:28.114395	\N	\N	f	\N	t	4	f
947	https://www.r4.com/articulos-y-analisis/valores/inditex-resultados-2t25-incumplen-previsiones-si-bien-el-inicio-de-las-ventas-3t25-acelera-el-crecimiento-mas-de-lo-previsto-mayor-impacto-negativo-de-la-divisa-previsto-para-2025e	549	4	2025-11-04 21:42:54.989151	2025-11-05 08:03:36.085113	\N	\N	f	\N	t	4	f
1014	https://www.r4.com/articulos-y-analisis/valores/merlin-properties-emision-de-bonos-verdes-por-importe-de-550-mln-eur-al-3-50	558	4	2025-11-04 21:44:44.899985	2025-11-05 08:05:13.614845	\N	\N	f	\N	t	4	f
1047	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/renta-fija-la-esperanza-de-las-vacunas-impulsa-con-fuerza-a-los-mercados-a-final-del-ano	606	4	2025-11-04 21:45:24.06301	2025-11-05 08:05:54.735772	\N	\N	f	\N	t	4	f
1072	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/las-bolsas-se-sumergen-en-el-tsunami-de-la-inteligencia-artificial-y-de-la-superliquidez	671	4	2025-11-04 21:46:10.20162	2025-11-05 08:06:37.961585	\N	\N	f	\N	t	4	f
1079	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-lado-oscuro-de-la-inteligencia-artificial-que-hay-que-conocer	681	4	2025-11-04 21:46:23.519102	2025-11-05 08:06:49.906231	\N	\N	f	\N	t	4	f
1110	https://www.r4.com/articulos-y-analisis/valores/melia-hoteles-supera-previsiones-a-nivel-operativo-buena-evolucion-de-cara-a-la-temporada-de-verano-mejora-del-objetivo-de-deuda-2025e	691	4	2025-11-04 21:47:04.733823	2025-11-05 08:07:29.694357	\N	\N	f	\N	t	4	f
1120	https://www.r4.com/articulos-y-analisis/valores/sector-financiero-potenciales-limitados-motivos-para-caer-tambien	692	4	2025-11-04 21:47:16.439639	2025-11-05 08:07:42.935309	\N	\N	f	\N	t	4	f
1141	https://www.r4.com/articulos-y-analisis/tecnico/el-fatidico-viernes-cripto-que-es-alcista-a-6-meses-para-el-s-p500	722	4	2025-11-04 21:47:45.854155	2025-11-05 08:08:08.571067	\N	\N	f	\N	t	4	f
1157	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-activos-globales-a-cierre-de-agosto-de-2025	748	4	2025-11-04 21:48:11.708572	2025-11-05 08:08:28.006593	\N	\N	f	\N	t	4	f
1167	https://www.r4.com/articulos-y-analisis/cripto/altibajos-incertidumbre-global	759	4	2025-11-04 21:48:23.391207	2025-11-05 08:08:41.892966	\N	\N	f	\N	t	4	f
1173	https://www.r4.com/normativa/politica-privacidad/politica-privacidadnoclientes	760	4	2025-11-04 21:48:30.402863	2025-11-05 08:08:49.25392	\N	\N	f	\N	t	4	f
1187	https://www.r4.com/inversion-para-todos/identifica-los-gastos-innecesarios-y-mejora-tus-finanzas	791	4	2025-11-04 21:48:52.783301	2025-11-05 08:09:12.148754	\N	\N	f	\N	t	4	f
1201	https://www.r4.com/inversion-para-todos/descubre-la-diferencia-entre-gasto-e-inversion	802	4	2025-11-04 21:49:14.583554	2025-11-05 08:09:34.215807	\N	\N	f	\N	t	4	f
1218	https://www.r4.com/inversion-para-todos/que-son-small-caps	807	4	2025-11-04 21:49:44.259415	2025-11-05 08:10:03.444278	\N	\N	f	\N	t	4	f
1220	https://www.r4.com/inversion-para-todos/principales-indices-bursatiles-y-sus-valores	809	4	2025-11-04 21:49:48.074036	2025-11-05 08:10:06.487368	\N	\N	f	\N	t	4	f
1224	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-megatendencias-medio-ambiente-entre-los-20-fondos-clasificados-como-art-9-cumpliendo-con-las-maximas-exigencias-de-sostenibilidad	816	4	2025-11-04 21:49:55.43893	2025-11-05 08:10:12.675724	\N	\N	f	\N	t	4	f
1253	https://www.r4.com/inversion-para-todos/bienvenida-ahorrador-inversor	822	4	2025-11-04 21:50:47.624834	2025-11-05 08:11:01.493838	\N	\N	f	\N	t	4	f
1267	https://www.r4.com/inversion-para-todos/laboratorios-rovi-empresa-exito	844	4	2025-11-04 21:51:12.659289	2025-11-05 08:11:23.707837	\N	\N	f	\N	t	4	f
1274	https://www.r4.com/inversion-para-todos/evolucion-comunicacion-digital	844	4	2025-11-04 21:51:25.538462	2025-11-05 08:11:34.724399	\N	\N	f	\N	t	4	f
1277	https://www.r4.com/inversion-para-todos/consejos-ciberseguridad-robo-datos	844	4	2025-11-04 21:51:30.436887	2025-11-05 08:11:40.172532	\N	\N	f	\N	t	4	f
1288	https://www.r4.com/inversion-para-todos/en-que-afecta-el-coronavirus-a-la-inversion-y-otras-crisis-sanitarias	866	4	2025-11-04 21:51:48.795395	2025-11-05 08:11:58.633162	\N	\N	f	\N	t	4	f
1299	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-banco-obtiene-un-beneficio-neto-de-8-8-millones-de-euros-en-el-primer-trimestre-de-2025-un-28-4-mas-que-en-el-mismo-periodo-de-2024	886	4	2025-11-04 21:52:07.298112	2025-11-05 08:12:13.803246	\N	\N	f	\N	t	4	f
1323	https://www.r4.com/articulos-y-analisis/valores/bbva-la-cnmc-aprueba-la-opa-sobre-sabadell	912	5	2025-11-04 21:52:50.751638	2025-11-05 08:12:44.197271	\N	\N	f	\N	t	4	f
1330	https://www.r4.com/articulos-y-analisis/valores/enagas-previo-2024-esperamos-ebitda-mejor-que-la-guia-y-bdi-recogiendo-minusvalias-actualizaran-estrategia	922	5	2025-11-04 21:53:04.65441	2025-11-05 08:12:52.442814	\N	\N	f	\N	t	4	f
1350	https://www.r4.com/articulos-y-analisis/valores/previo-endesa-9m24-crecimiento-de-medio-digito-previsto-sigue-poniendo-exigencia-en-4t-para-alcanzar-objetivos	935	5	2025-11-04 21:53:44.302069	2025-11-05 08:13:25.290408	\N	\N	f	\N	t	4	f
1366	https://www.r4.com/articulos-y-analisis/valores/ferrovial-2023-el-rendimiento-de-la-tesoreria-permite-a-la-caja-neta-mejorar-la-perspectiva	945	5	2025-11-04 21:54:08.997	2025-11-05 08:14:00.29835	\N	\N	f	\N	t	4	f
1370	https://www.r4.com/articulos-y-analisis/valores/inditex-resultados-2t-24-en-linea-e-inicio-de-las-ventas-3t-24-a-nivel-operativo-buen-inicio-en-2t-24-tambien-en-linea-mayor-impacto-negativo-de-la-divisa-2024e-p-o-49-7-eur-mantener	955	5	2025-11-04 21:54:14.60684	2025-11-05 08:14:09.092958	\N	\N	f	\N	t	4	f
1446	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/mercados-emergentes-trump-no-pudo-pararlos-	1027	5	2025-11-04 21:56:12.059655	2025-11-05 08:16:41.955455	\N	\N	f	\N	t	4	f
1397	https://www.r4.com/articulos-y-analisis/valores/sacyr-investor-day-2024-crecimiento-a-largo-plazo-que-podria-acelerarse-a-partir-de-2026	983	5	2025-11-04 21:54:52.900204	2025-11-05 08:15:01.342454	\N	\N	f	\N	t	4	f
1406	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-3t24-los-resultados-superan-previsiones-a-nivel-operativo-sin-cambios-en-la-guia-p-o-30-7-eur-sobreponderar	991	5	2025-11-04 21:55:04.175725	2025-11-05 08:15:19.491268	\N	\N	f	\N	t	4	f
1407	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-previo-3t-24-deterioro-previsto-en-3t-24-esperamos-que-2s-24-marque-la-parte-baja-del-ciclo-a-la-espera-de-una-recuperacion-de-los-precios-p-o-30-7-eur-sobreponderar	991	5	2025-11-04 21:55:05.43917	2025-11-05 08:15:21.702014	\N	\N	f	\N	t	4	f
1439	https://www.r4.com/articulos-y-analisis/valores/merlin-properties-revela-posibles-estrategias-sobre-los-data-centers-en-su-jga	1023	5	2025-11-04 21:55:59.982259	2025-11-05 08:16:23.967946	\N	\N	f	\N	t	4	f
1737	https://www.r4.com/inversion-para-todos/modificar-borrador-declaracion-renta	1242	5	2025-11-04 22:04:20.574707	2025-11-05 08:25:14.005487	\N	\N	f	\N	t	4	f
1535	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-1t25-mejores-en-terminos-absolutos-con-un-positivo-margen-del-4-3	1096	5	2025-11-04 21:58:21.695896	2025-11-05 08:20:00.845297	\N	\N	f	\N	t	4	f
1564	https://www.r4.com/articulos-y-analisis/valores/melia-hoteles-3t-24-supera-previsiones-buena-evolucion-del-negocio-en-europa-y-espana-esperamos-recuperacion-de-las-reservas-en-america-mantiene-la-guia-2024e-p-o-9-4-eur	1117	5	2025-11-04 21:59:15.056691	2025-11-05 08:20:49.491543	\N	\N	f	\N	t	4	f
1620	https://www.r4.com/articulos-y-analisis/valores/vidrala-2t24-los-cambios-en-el-perimetro-permiten-sostener-los-margenes-a-pesar-de-la-debil-demanda-en-el-sur-de-europa	1131	5	2025-11-04 22:00:58.45122	2025-11-05 08:22:18.195621	\N	\N	f	\N	t	4	f
1708	https://www.r4.com/inversion-para-todos/category/curiosidades-financieras/page/4	1208	5	2025-11-04 22:03:31.438012	2025-11-05 08:24:26.439798	\N	\N	f	\N	t	4	f
1722	https://www.r4.com/portal?TX=goto&FWD=FCH_FND_NOLOGADO&PAG=5&HOJA=2&COD_ISIN=ES0113118006&r4gheader	1218	5	2025-11-04 22:03:56.250683	2025-11-05 08:24:49.848073	\N	\N	f	\N	t	4	f
1751	https://www.r4.com/portal?TX=company&OPC=4&ISIN=ES0183746314&MKT=MCO	1305	5	2025-11-04 22:04:41.482314	2025-11-05 08:25:35.039972	\N	\N	f	\N	t	4	f
1760	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-gestora-celebra-su-iii-mesa-de-expertos-con-las-claves-para-invertir-en-2025	1308	5	2025-11-04 22:04:56.06021	2025-11-05 08:25:45.556406	\N	\N	f	\N	t	4	f
1788	https://www.r4.com/articulos-y-analisis/valores/bbva-resultados-3t24-los-volumenes-siguen-apoyando-el-crecimiento-de-ingresos-atencion-al-coste-de-riesgo-en-mexico-y-turquia-mantener-p-o-10-62-eur-acc	1329	6	2025-11-04 22:05:54.520735	2025-11-05 08:26:29.637013	\N	\N	f	\N	t	4	f
1808	https://www.r4.com/articulos-y-analisis/valores/conclusiones-redeia-2024-guia-p-l-2025-alineada-con-expectativas-elevan-prevision-de-inversiones-pendientes-de-la-regulacion	1343	6	2025-11-04 22:06:33.845374	2025-11-05 08:27:01.428912	\N	\N	f	\N	t	4	f
1841	https://www.r4.com/articulos-y-analisis/valores/dominion-vende-su-participacion-en-seis-parques-fotovoltaicos-en-republica-dominicana	1390	6	2025-11-04 22:07:42.116777	2025-11-05 08:27:57.080405	\N	\N	f	\N	t	4	f
1857	https://www.r4.com/articulos-y-analisis/valores/arcelormittal-4t23-resultados-mas-debiles-de-lo-previsto-excepto-a-nivel-ebitda-que-superan-previsiones-se-espera-mejoria-para-los-proximos-trimestres-aunque-la-visibilidad-sigue-siendo-limitada	1413	6	2025-11-04 22:08:15.419346	2025-11-05 08:28:19.826016	\N	\N	f	\N	t	4	f
1885	https://www.r4.com/articulos-y-analisis/valores/telefonica-conferencia-4t24-la-revision-estrategica-determinara-la-nueva-hoja-de-ruta-generacion-de-caja-y-desapalancamiento-para-participar-en-un-futuro-proceso-de-consolidacion-europeo	1461	6	2025-11-04 22:09:03.548887	2025-11-05 08:29:00.344915	\N	\N	f	\N	t	4	f
1927	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/trump-convence-a-la-bolsa-y-a-los-bonos-pero-no-al-dolar-y-a-la-fed	1487	6	2025-11-04 22:10:08.714762	2025-11-05 08:29:53.161242	\N	\N	f	\N	t	4	f
2058	https://www.r4.com/articulos-y-analisis/valores/sector-defensa-el-gobierno-anuncia-el-aumento-del-gasto-en-defensa	1644	6	2025-11-04 22:13:47.50406	2025-11-05 08:32:57.255281	\N	\N	f	\N	t	4	f
2076	https://www.r4.com/articulos-y-analisis/tecnico/el-eurostoxx-50-acomete-por-quinta-vez-en-el-ano-su-muro-otro-grafico-que-demuestra-la-probabilidad-de-que-en-usa-queda-mas-subida	1669	6	2025-11-04 22:14:16.345179	2025-11-05 08:33:26.167451	\N	\N	f	\N	t	4	f
4177	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-megatendencias-salud-a-cierre-de-julio-de-2025	1680	6	2025-11-05 08:33:49.089932	\N	\N	\N	f	\N	t	4	f
4179	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-megatendencias-medio-ambiente-a-cierre-de-julio-de-2025	1680	6	2025-11-05 08:33:53.764905	\N	\N	\N	f	\N	t	4	f
4181	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-activos-globales-a-cierre-de-julio-de-2025	1680	6	2025-11-05 08:33:57.030473	\N	\N	\N	f	\N	t	4	f
4185	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-svb-crea-un-momento-minsky-y-pone-a-prueba-el-modelo-de-ajuste-ordenado	1702	6	2025-11-05 08:34:04.777611	\N	\N	\N	f	\N	t	4	f
4187	https://www.r4.com/inversion-para-todos/que-son-activos-refugio	1708	6	2025-11-05 08:34:08.781714	\N	\N	\N	f	\N	t	4	f
4189	https://www.r4.com/inversion-para-todos/que-es-la-asertividad	1708	6	2025-11-05 08:34:12.087823	\N	\N	\N	f	\N	t	4	f
4191	https://www.r4.com/inversion-para-todos/normas-convivencia-trabajo	1708	6	2025-11-05 08:34:15.330899	\N	\N	\N	f	\N	t	4	f
4193	https://www.r4.com/inversion-para-todos/velas-japonesas-origen-y-significado-de-este-indicador	1708	6	2025-11-05 08:34:18.636924	\N	\N	\N	f	\N	t	4	f
4196	https://www.r4.com/inversion-para-todos/que-es-el-capitalismo-consciente	1708	6	2025-11-05 08:34:23.247324	\N	\N	\N	f	\N	t	4	f
4198	https://www.r4.com/inversion-para-todos/que-es-inversion-tematica	1708	6	2025-11-05 08:34:26.523649	\N	\N	\N	f	\N	t	4	f
4200	https://www.r4.com/inversion-para-todos/que-es-rebote-gato-muerto	1708	6	2025-11-05 08:34:29.592245	\N	\N	\N	f	\N	t	4	f
4204	https://www.r4.com/broker-online?soc=blogr4:asesoramiento:texto	1734	6	2025-11-05 08:34:35.425316	\N	\N	\N	f	\N	t	4	f
4206	https://www.r4.com/inversion-para-todos/que-es-value-investing-y-como-funciona	1738	6	2025-11-05 08:34:38.283743	\N	\N	\N	f	\N	t	4	f
4208	https://www.r4.com/inversion-para-todos/depositos-estructurados-vs-inversion	1738	6	2025-11-05 08:34:42.047653	\N	\N	\N	f	\N	t	4	f
4210	https://www.r4.com/inversion-para-todos/diferencias-tin-tae	1738	6	2025-11-05 08:34:45.527753	\N	\N	\N	f	\N	t	4	f
4212	https://www.r4.com/inversion-para-todos/que-es-plusvalia-del-muerto	1738	6	2025-11-05 08:34:48.536137	\N	\N	\N	f	\N	t	4	f
4214	https://www.r4.com/inversion-para-todos/que-son-plan-pension-ciclo-de-vida	1738	6	2025-11-05 08:34:52.32898	\N	\N	\N	f	\N	t	4	f
4216	https://www.r4.com/inversion-para-todos/resumen-2020-inversion	1744	6	2025-11-05 08:34:55.499185	\N	\N	\N	f	\N	t	4	f
4218	https://www.r4.com/inversion-para-todos/inversion-hidrogeno-megatendencia	1744	6	2025-11-05 08:34:58.779814	\N	\N	\N	f	\N	t	4	f
4220	https://www.r4.com/inversion-para-todos/diferencias-plan-pensiones-plan-jubilacion	1744	6	2025-11-05 08:35:02.029947	\N	\N	\N	f	\N	t	4	f
4222	https://www.r4.com/inversion-para-todos/que-es-selector-fondos	1744	6	2025-11-05 08:35:05.6135	\N	\N	\N	f	\N	t	4	f
4224	https://www.r4.com/inversion-para-todos/regla-del-jubilacion	1744	6	2025-11-05 08:35:09.047348	\N	\N	\N	f	\N	t	4	f
1449	https://www.r4.com/servicios-gestion/planificacion-financiera/que-es-planificacion-financiera	1035	5	2025-11-04 21:56:15.911814	2025-11-05 08:16:48.235943	\N	\N	f	\N	t	4	f
1554	https://www.r4.com/articulos-y-analisis/valores/tubacex-lanzamiento-de-la-conexion-premium-para-octg	1107	5	2025-11-04 21:58:55.702764	2025-11-05 08:20:34.448943	\N	\N	f	\N	t	4	f
1574	https://www.r4.com/articulos-y-analisis/valores/sector-financiero-previo-resultados-3t24-el-margen-de-intereses-seguira-siendo-protagonista	1126	5	2025-11-04 21:59:36.272649	2025-11-05 08:21:02.698924	\N	\N	f	\N	t	4	f
1638	https://www.r4.com/articulos-y-analisis/valores/indra-resultados-2t-25-que-superan-previsiones-a-nivel-operativo-gran-evolucion-de-la-contratacion-en-2t-mantiene-la-guia-2025e	1133	5	2025-11-04 22:01:35.549413	2025-11-05 08:22:49.333943	\N	\N	f	\N	t	4	f
1712	https://www.r4.com/inversion-para-todos/que-es-estanflacion	1214	5	2025-11-04 22:03:38.567083	2025-11-05 08:24:33.14917	\N	\N	f	\N	t	4	f
1757	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-banco-obtiene-un-beneficio-neto-en-el-2024-de-32-1-millones-de-euros-un-23-mas-que-en-el-ano-anterior	1308	5	2025-11-04 22:04:48.954075	2025-11-05 08:25:42.081347	\N	\N	f	\N	t	4	f
1763	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-banco-pone-en-marcha-carteras-easy-la-herramienta-de-inversion-que-combina-la-ia-con-la-experiencia-profesional	1308	5	2025-11-04 22:05:03.016797	2025-11-05 08:25:50.272361	\N	\N	f	\N	t	4	f
1800	https://www.r4.com/articulos-y-analisis/valores/naturgy-2024-esperamos-que-alcancen-objetivos-visibilidad-previsiblemente-con-el-plan-estrategico	1342	6	2025-11-04 22:06:17.666756	2025-11-05 08:26:49.673589	\N	\N	f	\N	t	4	f
1827	https://www.r4.com/articulos-y-analisis/valores/iberdrola-1t24-recogiendo-plusvalias-por-la-venta-de-activos-en-mexico-revisan-guia-2024-al-alza-por-buena-marcha-operativa	1345	6	2025-11-04 22:07:15.351623	2025-11-05 08:27:32.63169	\N	\N	f	\N	t	4	f
1845	https://www.r4.com/articulos-y-analisis/valores/dominion-pre-4t24-trimestre-de-transicion-previo-a-la-reactivacion-de-proyectos-de-ee-rr	1390	6	2025-11-04 22:07:50.546698	2025-11-05 08:28:03.80461	\N	\N	f	\N	t	4	f
1881	https://www.r4.com/articulos-y-analisis/valores/telefonica-desconsolidacion-de-argentina-y-peru-y-depreciacion-de-divisas-latam	1461	6	2025-11-04 22:08:58.660571	2025-11-05 08:28:55.462033	\N	\N	f	\N	t	4	f
1918	https://www.r4.com/articulos-y-analisis/ideas/enagas-reemplaza-a-iberdrola-en-las-carteras-de-acciones	1478	6	2025-11-04 22:09:54.064207	2025-11-05 08:29:42.156487	\N	\N	f	\N	t	4	f
1928	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/junio-empieza-muy-bien-en-las-bolsas-pero-el-fantasma-de-la-crisis-de-deuda-sigue-flotando-en-el-ambiente	1488	6	2025-11-04 22:10:10.916203	2025-11-05 08:29:54.531035	\N	\N	f	\N	t	4	f
2059	https://www.r4.com/articulos-y-analisis/valores/indra-resultados-4t24-que-superan-a-nivel-operativo-guia-2025e-por-encima-de-nuestras-estimaciones	1644	6	2025-11-04 22:13:48.891979	2025-11-05 08:32:58.469378	\N	\N	f	\N	t	4	f
4173	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-renta-fija-mixto-a-cierre-de-julio-de-2025	1680	6	2025-11-05 08:33:43.431658	\N	\N	\N	f	\N	t	4	f
4178	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-bolsa-espana-a-cierre-de-julio-de-2025	1680	6	2025-11-05 08:33:51.30394	\N	\N	\N	f	\N	t	4	f
4180	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-megatendencias-tecnologia-a-cierre-de-julio-de-2025	1680	6	2025-11-05 08:33:54.941927	\N	\N	\N	f	\N	t	4	f
4182	https://www.r4.com/articulos-y-analisis/fondos/6	1680	6	2025-11-05 08:33:59.177266	\N	\N	\N	f	\N	t	4	f
4186	https://www.r4.com/inversion-para-todos/mujeres-en-economia	1703	6	2025-11-05 08:34:07.063264	\N	\N	\N	f	\N	t	4	f
4188	https://www.r4.com/inversion-para-todos/mejores-consejos-tipos-inversiones-para-jovenes	1708	6	2025-11-05 08:34:10.439245	\N	\N	\N	f	\N	t	4	f
4190	https://www.r4.com/inversion-para-todos/que-es-pip-forex	1708	6	2025-11-05 08:34:13.643803	\N	\N	\N	f	\N	t	4	f
4192	https://www.r4.com/inversion-para-todos/que-es-cuadruple-hora-bruja	1708	6	2025-11-05 08:34:17.098996	\N	\N	\N	f	\N	t	4	f
4194	https://www.r4.com/inversion-para-todos/que-es-la-paradoja-del-ahorro	1708	6	2025-11-05 08:34:20.151387	\N	\N	\N	f	\N	t	4	f
4197	https://www.r4.com/inversion-para-todos/recomendaciones-dia-del-libro	1708	6	2025-11-05 08:34:24.784629	\N	\N	\N	f	\N	t	4	f
4199	https://www.r4.com/inversion-para-todos/formula-del-interes-compuesto	1708	6	2025-11-05 08:34:28.072188	\N	\N	\N	f	\N	t	4	f
4201	https://www.r4.com/inversion-para-todos/6-articulos-sobre-inversion	1708	6	2025-11-05 08:34:31.155104	\N	\N	\N	f	\N	t	4	f
4205	https://www.r4.com/serviciosr4/asesoramiento-puntual?soc=blogr4:asesoramiento:texto	1735	6	2025-11-05 08:34:36.711753	\N	\N	\N	f	\N	t	4	f
4207	https://www.r4.com/inversion-para-todos/ciclos-ahorrador-inversor-2021	1738	6	2025-11-05 08:34:40.391772	\N	\N	\N	f	\N	t	4	f
4209	https://www.r4.com/inversion-para-todos/convalidar-cotizacion-en-extranjero	1738	6	2025-11-05 08:34:43.725813	\N	\N	\N	f	\N	t	4	f
4211	https://www.r4.com/inversion-para-todos/que-son-derechos-consolidados-plan-de-pensiones	1738	6	2025-11-05 08:34:47.020763	\N	\N	\N	f	\N	t	4	f
4213	https://www.r4.com/inversion-para-todos/que-son-bandas-de-bollinger	1738	6	2025-11-05 08:34:50.096464	\N	\N	\N	f	\N	t	4	f
4215	https://www.r4.com/inversion-para-todos/que-es-apalancamiento-en-trading	1744	6	2025-11-05 08:34:53.962498	\N	\N	\N	f	\N	t	4	f
4217	https://www.r4.com/inversion-para-todos/como-invertir-tus-ahorros-para-una-jubilacion-tranquila	1744	6	2025-11-05 08:34:57.059356	\N	\N	\N	f	\N	t	4	f
4219	https://www.r4.com/inversion-para-todos/los-sectores-mas-afectados-para-bien-y-para-mal-en-bolsa-tras-la-crisis-del-covid	1744	6	2025-11-05 08:35:00.310062	\N	\N	\N	f	\N	t	4	f
4221	https://www.r4.com/inversion-para-todos/que-es-inversor-institucional	1744	6	2025-11-05 08:35:03.589932	\N	\N	\N	f	\N	t	4	f
4223	https://www.r4.com/inversion-para-todos/que-es-inversion-por-factores	1744	6	2025-11-05 08:35:07.362305	\N	\N	\N	f	\N	t	4	f
4226	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-y-traders-business-school-se-alian-para-potenciar-la-mejor-formacion-sobre-inversiones-de-habla-hispana	1766	6	2025-11-05 08:35:11.745158	\N	\N	\N	f	\N	t	4	f
4227	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-banco-ha-obtenido-un-beneficio-neto-de-15-3-millones-de-euros-en-el-1s24-un-7-mas-que-en-el-mismo-periodo-del-ano-anterior	1767	6	2025-11-05 08:35:13.032776	\N	\N	\N	f	\N	t	4	f
4228	https://www.r4.com/articulos-y-analisis/noticias-renta4/antonio-gonzalez-responsable-de-gestion-de-activos-de-renta-4-banco-en-la-prestigiosa-lista-40-under-40-de-citywire-a-nivel-europeo	1767	6	2025-11-05 08:35:15.296855	\N	\N	\N	f	\N	t	4	f
4229	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-colabora-con-tutecho-primera-socimi-de-impacto-que-cotiza-en-bolsa	1767	6	2025-11-05 08:35:16.567697	\N	\N	\N	f	\N	t	4	f
4230	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-banco-continua-creciendo-de-manera-satisfactoria-en-las-principales-variables-de-negocio-durante-el-primer-trimestre-de-2024	1767	6	2025-11-05 08:35:17.75271	\N	\N	\N	f	\N	t	4	f
4231	https://www.r4.com/articulos-y-analisis/noticias-renta4/los-gestores-de-fondos-analizan-las-oportunidades-en-renta-fija-y-variable-en-el-investor-s-day-2024-de-renta-4-gestora	1767	6	2025-11-05 08:35:18.945456	\N	\N	\N	f	\N	t	4	f
4232	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-lanza-el-fondo-renta-4-cripto-fil-centrado-en-la-inversion-en-criptomonedas	1767	6	2025-11-05 08:35:20.139013	\N	\N	\N	f	\N	t	4	f
4233	https://www.r4.com/articulos-y-analisis/noticias-renta4/la-nueva-plataforma-de-renta-fija-de-renta-4-banco-multiplica-por-diez-las-operaciones-online	1767	6	2025-11-05 08:35:21.345742	\N	\N	\N	f	\N	t	4	f
4234	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-refuerza-sus-servicios-corporativos-gracias-a-un-acuerdo-con-sigrun-partners	1767	6	2025-11-05 08:35:22.552726	\N	\N	\N	f	\N	t	4	f
4235	https://www.r4.com/articulos-y-analisis/area-prensa/6	1767	6	2025-11-05 08:35:23.829478	\N	\N	\N	f	\N	t	4	f
4236	http://www.r4.com/politicas/politica-privacidad	1769	6	2025-11-05 08:35:25.113966	\N	\N	\N	f	\N	t	4	f
4238	http://www.r4.com/content/rentabanco/r4/es/normativa/politica-cookies	1769	6	2025-11-05 08:35:28.208268	\N	\N	\N	f	\N	t	4	f
4239	https://www.r4.com/articulos-y-analisis/valores/indexa-capital-inicio-de-cobertura-indexa-capital-gestion-automatizada-gestion-diferencial	1771	7	2025-11-05 08:35:29.478747	\N	\N	\N	f	\N	t	4	f
4240	https://www.r4.com/articulos-y-analisis/valores/sabadell-resultados-1t25-se-mantienen-guias-2025-mejora-del-objetivo-de-remuneracion-al-accionista-para-2025	1774	7	2025-11-05 08:35:30.777025	\N	\N	\N	f	\N	t	4	f
4241	https://www.r4.com/articulos-y-analisis/valores/banco-sabadell-buenas-perspectivas-a-la-espera-del-nuevo-plan-estrategico	1774	7	2025-11-05 08:35:32.005797	\N	\N	\N	f	\N	t	4	f
4242	https://www.r4.com/articulos-y-analisis/valores/sabadell-4t24-buenas-perspectivas-para-2025-que-apoyan-la-politica-de-dividendos	1774	7	2025-11-05 08:35:34.33615	\N	\N	\N	f	\N	t	4	f
4243	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0113860A34	1774	7	2025-11-05 08:35:35.59482	\N	\N	\N	f	\N	t	4	f
4244	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0113860A34/3	1774	7	2025-11-05 08:35:36.81961	\N	\N	\N	f	\N	t	4	f
4245	https://www.r4.com/articulos-y-analisis/valores/bankinter-4t24-buenas-cifras-operativas-con-algunas-guias-no-cumplidas-y-roe-del-18	1781	7	2025-11-05 08:35:39.024159	\N	\N	\N	f	\N	t	4	f
4246	https://www.r4.com/articulos-y-analisis/valores/bankinter-3t24-volumenes-y-comisiones-compensaran-el-impacto-negativo-del-proceso-de-repreciacion-de-la-cartera-de-credito	1781	7	2025-11-05 08:35:41.308154	\N	\N	\N	f	\N	t	4	f
4247	https://www.r4.com/articulos-y-analisis/valores/bankinter-resultados-3t24-comisiones-netas-para-compensar-margen-de-intereses-mantener-p-o-8-33-eur-acc	1781	7	2025-11-05 08:35:42.501227	\N	\N	\N	f	\N	t	4	f
4248	https://www.r4.com/articulos-y-analisis/valores/bankinter-la-visibilidad-de-ingresos-se-mantiene	1781	7	2025-11-05 08:35:43.743078	\N	\N	\N	f	\N	t	4	f
4249	https://www.r4.com/articulos-y-analisis/valores/bankinter-primeras-impresiones-2t24-ingresos-solidos-vs-coste-de-riesgo-al-alza-sobreponderar-p-o-7-9-eur-acc	1781	7	2025-11-05 08:35:44.93533	\N	\N	\N	f	\N	t	4	f
4250	https://www.r4.com/articulos-y-analisis/valores/bankinter-conferencia-de-resultados-1t24-potencial-revision-al-alza-de-la-guia-de-margen-de-intereses	1781	7	2025-11-05 08:35:46.129632	\N	\N	\N	f	\N	t	4	f
4251	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0113679I37	1781	7	2025-11-05 08:35:47.294545	\N	\N	\N	f	\N	t	4	f
4252	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0113679I37/3	1781	7	2025-11-05 08:35:49.484312	\N	\N	\N	f	\N	t	4	f
4253	https://www.r4.com/articulos-y-analisis/valores/bbva-resultados-2t24-buena-evolucion-operativa-apoyado-por-volumenes-mantener-p-o-0-62-eur-acc	1790	7	2025-11-05 08:35:51.616377	\N	\N	\N	f	\N	t	4	f
4254	https://www.r4.com/articulos-y-analisis/valores/bbva-aprueba-la-emision-de-cocos-por-importe-de-750-millones-de-euros	1790	7	2025-11-05 08:35:53.852608	\N	\N	\N	f	\N	t	4	f
4255	https://www.r4.com/articulos-y-analisis/valores/opa-bbva-sabadell-plazos-del-proceso-de-opa	1790	7	2025-11-05 08:35:56.151485	\N	\N	\N	f	\N	t	4	f
4256	https://www.r4.com/articulos-y-analisis/valores/bbva-lanza-una-opa-hostil-sobre-banco-sabadell	1790	7	2025-11-05 08:35:57.353548	\N	\N	\N	f	\N	t	4	f
4257	https://www.r4.com/articulos-y-analisis/valores/sabadell-denuncia-ante-la-cnmv-a-bbva-por-vulneracion-de-la-ley-de-opas	1790	7	2025-11-05 08:35:58.546097	\N	\N	\N	f	\N	t	4	f
4258	https://www.r4.com/articulos-y-analisis/valores/sabadell-rechaza-la-oferta-de-bbva	1790	7	2025-11-05 08:36:00.82195	\N	\N	\N	f	\N	t	4	f
4259	https://www.r4.com/articulos-y-analisis/valores/bbva-lanza-una-propuesta-de-fusion-por-absorcion-sobre-banco-sabadell	1790	7	2025-11-05 08:36:03.081692	\N	\N	\N	f	\N	t	4	f
4260	https://www.r4.com/articulos-y-analisis/valores/bbva-1t24-mejoran-guia-de-ingresos-y-beneficio-neto-para-el-grupo	1790	7	2025-11-05 08:36:05.378791	\N	\N	\N	f	\N	t	4	f
4261	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0113211835/5	1790	7	2025-11-05 08:36:07.705113	\N	\N	\N	f	\N	t	4	f
4262	https://www.r4.com/articulos-y-analisis/valores/conclusiones-naturgy-1s24-pendientes-de-conocer-el-plan-2025-2030-en-el-corto-plazo	1801	7	2025-11-05 08:36:09.775013	\N	\N	\N	f	\N	t	4	f
4263	https://www.r4.com/articulos-y-analisis/valores/naturgy-1s24-sorpresa-positiva-por-buena-marcha-de-los-negocios-y-extraordinarios	1801	7	2025-11-05 08:36:12.094247	\N	\N	\N	f	\N	t	4	f
4264	https://www.r4.com/articulos-y-analisis/valores/naturgy-elevados-niveles-de-incertidumbre-en-entorno-energetico-previo-1s	1801	7	2025-11-05 08:36:13.301249	\N	\N	\N	f	\N	t	4	f
4265	https://www.r4.com/articulos-y-analisis/valores/naturgy-2023-positiva-evolucion-de-la-deuda-neta	1801	7	2025-11-05 08:36:14.507295	\N	\N	\N	f	\N	t	4	f
4266	https://www.r4.com/articulos-y-analisis/valores/naturgy-2023-veremos-si-dan-visibilidad-de-cara-a-2024-elevamos-recomendacion-a-mantener	1801	7	2025-11-05 08:36:16.840032	\N	\N	\N	f	\N	t	4	f
4267	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0116870314	1801	7	2025-11-05 08:36:18.083093	\N	\N	\N	f	\N	t	4	f
4268	https://www.r4.com/articulos-y-analisis/valores/previo-redeia-2024-se-desconsolidara-hispasat-entrada-de-caja-por-venta-en-2025	1810	7	2025-11-05 08:36:19.288412	\N	\N	\N	f	\N	t	4	f
4269	https://www.r4.com/articulos-y-analisis/valores/redeia-9m24-bajan-dividendo-2025-estaba-previsto	1810	7	2025-11-05 08:36:20.482066	\N	\N	\N	f	\N	t	4	f
4270	https://www.r4.com/articulos-y-analisis/valores/previo-redeia-9m24-descenso-previsto-por-salida-de-activos-pre98-inversiones-al-alza	1810	7	2025-11-05 08:36:22.642138	\N	\N	\N	f	\N	t	4	f
4271	https://www.r4.com/articulos-y-analisis/valores/redeia-pendientes-de-la-nueva-regulacion-elevamos-recomendacion	1810	7	2025-11-05 08:36:24.79131	\N	\N	\N	f	\N	t	4	f
4272	https://www.r4.com/articulos-y-analisis/valores/redeia-1s24-sin-sorpresas	1810	7	2025-11-05 08:36:25.986329	\N	\N	\N	f	\N	t	4	f
4273	https://www.r4.com/articulos-y-analisis/valores/previo-redeia-1s24-descenso-previsto-por-salida-de-activos-pre98-inversiones-al-alza	1810	7	2025-11-05 08:36:28.273693	\N	\N	\N	f	\N	t	4	f
4274	https://www.r4.com/articulos-y-analisis/valores/redeia-1t24-en-camino-para-alcanzar-la-guia	1810	7	2025-11-05 08:36:30.494509	\N	\N	\N	f	\N	t	4	f
4275	https://www.r4.com/articulos-y-analisis/valores/conclusiones-redeia-2023-guia-2024-alineada-con-las-expectativas	1810	7	2025-11-05 08:36:32.901042	\N	\N	\N	f	\N	t	4	f
4276	https://www.r4.com/articulos-y-analisis/valores/redeia-2023-superan-ligeramente-nuestra-prevision-de-beneficio-neto	1810	7	2025-11-05 08:36:34.104516	\N	\N	\N	f	\N	t	4	f
4277	https://www.r4.com/articulos-y-analisis/valores/previo-redeia-2023-ligera-mejora-de-resultados-deuda-neta-al-alza-por-capex-creciente	1810	7	2025-11-05 08:36:36.600597	\N	\N	\N	f	\N	t	4	f
4278	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0173093024	1810	7	2025-11-05 08:36:37.885292	\N	\N	\N	f	\N	t	4	f
4279	https://www.r4.com/articulos-y-analisis/seguimiento-de-companias/acciona-energia-el-cambio-de-rumbo-se-consolidara-en-2025	1814	7	2025-11-05 08:36:39.915639	\N	\N	\N	f	\N	t	4	f
4280	https://www.r4.com/articulos-y-analisis/seguimiento-de-companias/acciona-energia-motivos-para-recuperar-el-optimismo	1815	7	2025-11-05 08:36:41.195474	\N	\N	\N	f	\N	t	4	f
4281	https://www.r4.com/articulos-y-analisis/valores/iberdrola-ampliacion-del-acuerdo-con-norges-ban	1828	7	2025-11-05 08:36:42.450491	\N	\N	\N	f	\N	t	4	f
4282	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0144580Y14	1828	7	2025-11-05 08:36:44.798754	\N	\N	\N	f	\N	t	4	f
4283	https://www.r4.com/articulos-y-analisis/informes-de-analisis/trump-sigue-marcando-el-ritmo-de-los-mercados	1846	7	2025-11-05 08:36:46.859971	\N	\N	\N	f	\N	t	4	f
4284	https://www.r4.com/articulos-y-analisis/valores/dominion-avanzando-pero-sin-despertar-la-atencion-del-mercado	1847	7	2025-11-05 08:36:48.05132	\N	\N	\N	f	\N	t	4	f
4285	https://www.r4.com/articulos-y-analisis/valores/dominion-2t24-prevemos-una-aceleracion-en-el-2s24-por-la-reactivacion-de-proyectos-y-la-falta-de-extraordinarios-negativos	1847	7	2025-11-05 08:36:49.25032	\N	\N	\N	f	\N	t	4	f
4286	https://www.r4.com/articulos-y-analisis/valores/dominion-pre-2t24-positiva-evolucion-en-servicios-que-compensa-el-retraso-en-proyectos	1847	7	2025-11-05 08:36:50.459306	\N	\N	\N	f	\N	t	4	f
4287	https://www.r4.com/articulos-y-analisis/valores/dominion-1t24-prevemos-avances-a-lo-largo-del-ejercicio	1847	7	2025-11-05 08:36:52.754278	\N	\N	\N	f	\N	t	4	f
4288	https://www.r4.com/articulos-y-analisis/valores/dominion-pre-1t24-un-trimestre-que-no-mostrara-la-fortaleza-del-negocio-subyacente	1847	7	2025-11-05 08:36:54.917263	\N	\N	\N	f	\N	t	4	f
4289	https://www.r4.com/articulos-y-analisis/valores/dominion-4t23-cifras-record-a-pesar-de-los-extraordinarios-negativos	1847	7	2025-11-05 08:36:56.106689	\N	\N	\N	f	\N	t	4	f
4290	https://www.r4.com/articulos-y-analisis/valores/dominion-pre-4t23-el-crecimiento-recurrente-y-la-consolidacion-de-proyectos-eleva-el-ebitda-que-marca-record-trimestral	1847	7	2025-11-05 08:36:58.378547	\N	\N	\N	f	\N	t	4	f
4291	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105130001	1847	7	2025-11-05 08:37:00.496385	\N	\N	\N	f	\N	t	4	f
4292	https://www.r4.com/articulos-y-analisis/valores/colonial-paris-impulsa-la-operativa-y-ofrece-proteccion-ante-el-ruido-en-espana	1869	7	2025-11-05 08:37:02.612281	\N	\N	\N	f	\N	t	4	f
4293	https://www.r4.com/articulos-y-analisis/valores/colonial-colocacion-acelerada-del-5-de-aguila-ltd-grupo-santo-domingo-con-un-descuento-del-5-08	1869	7	2025-11-05 08:37:05.057786	\N	\N	\N	f	\N	t	4	f
4294	https://www.r4.com/articulos-y-analisis/valores/colonial-cambio-de-director-general-en-su-filial-francesa-sfl	1869	7	2025-11-05 08:37:06.217519	\N	\N	\N	f	\N	t	4	f
4295	https://www.r4.com/articulos-y-analisis/valores/colonial-3t24-9m24-unos-buenos-resultados-que-apuntan-a-superar-objetivos-anuales	1869	7	2025-11-05 08:37:08.452961	\N	\N	\N	f	\N	t	4	f
4296	https://www.r4.com/articulos-y-analisis/valores/colonial-previo-3t24-solida-operativa-y-menor-apalancamiento	1869	7	2025-11-05 08:37:10.671806	\N	\N	\N	f	\N	t	4	f
4297	https://www.r4.com/articulos-y-analisis/valores/colonial-anuncia-la-fusion-por-absorcion-de-su-filial-francesa-sfl	1869	7	2025-11-05 08:37:13.153587	\N	\N	\N	f	\N	t	4	f
4298	https://www.r4.com/articulos-y-analisis/valores/colonial-moody-s-eleva-rating-hasta-baa1-desde-baa2-con-perspectiva-estable-desde-positiva	1869	7	2025-11-05 08:37:14.340469	\N	\N	\N	f	\N	t	4	f
4299	https://www.r4.com/articulos-y-analisis/valores/colonial-2t24-1s24-medalla-en-paris	1869	7	2025-11-05 08:37:15.515192	\N	\N	\N	f	\N	t	4	f
4300	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0139140174	1869	7	2025-11-05 08:37:16.78074	\N	\N	\N	f	\N	t	4	f
4301	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0139140174/3	1869	7	2025-11-05 08:37:18.050835	\N	\N	\N	f	\N	t	4	f
4302	https://www.r4.com/articulos-y-analisis/valores/metrovacesa-4t24-2024-un-extraordinario-4t24-para-superar-objetivos-y-estimaciones	1879	7	2025-11-05 08:37:19.205761	\N	\N	\N	f	\N	t	4	f
4303	https://www.r4.com/articulos-y-analisis/valores/metrovacesa-previo-4t24-el-trimestre-mas-fuerte-del-ano	1879	7	2025-11-05 08:37:20.346189	\N	\N	\N	f	\N	t	4	f
4304	https://www.r4.com/articulos-y-analisis/valores/metrovacesa-3t24-9m24-debiles-cifras-trimestrales-pero-con-reiteracion-de-objetivos-anuales	1879	7	2025-11-05 08:37:22.865608	\N	\N	\N	f	\N	t	4	f
4305	https://www.r4.com/articulos-y-analisis/valores/metrovacesa-previo-3t24-debil-trimestre-de-entregas-como-preludio-de-un-fuerte-cierre-de-ano	1879	7	2025-11-05 08:37:25.166906	\N	\N	\N	f	\N	t	4	f
4306	https://www.r4.com/articulos-y-analisis/valores/metrovacesa-2t24-1s24-buenos-resultados-con-reiteracion-de-objetivos-anuales	1879	7	2025-11-05 08:37:27.40329	\N	\N	\N	f	\N	t	4	f
4307	https://www.r4.com/articulos-y-analisis/valores/metrovacesa-1t24-muy-buenos-resultados	1879	7	2025-11-05 08:37:29.725485	\N	\N	\N	f	\N	t	4	f
4308	https://www.r4.com/articulos-y-analisis/valores/metrovacesa-previo-1t24-prometedor-inicio-de-ano	1879	7	2025-11-05 08:37:31.965512	\N	\N	\N	f	\N	t	4	f
4309	https://www.r4.com/articulos-y-analisis/valores/metrovacesa-4t23-2023-buenos-resultados-con-cumplimiento-de-objetivo-de-generacion-de-caja	1879	7	2025-11-05 08:37:34.380717	\N	\N	\N	f	\N	t	4	f
4310	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105122024	1879	7	2025-11-05 08:37:36.715172	\N	\N	\N	f	\N	t	4	f
4311	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105122024/3	1879	7	2025-11-05 08:37:37.908999	\N	\N	\N	f	\N	t	4	f
4312	https://www.r4.com/articulos-y-analisis/informes-de-analisis/geopolitica-bce-y-macro-protagonistas-de-la-semana	1884	7	2025-11-05 08:37:39.887874	\N	\N	\N	f	\N	t	4	f
4313	https://www.r4.com/articulos-y-analisis/informes-de-analisis/trump-toma-posesion-como-presidente-de-estados-unidos	1890	7	2025-11-05 08:37:42.242275	\N	\N	\N	f	\N	t	4	f
4314	https://www.r4.com/articulos-y-analisis/valores/telefonica-las-divisas-latam-complican-el-final-de-ano	1891	7	2025-11-05 08:37:44.598771	\N	\N	\N	f	\N	t	4	f
4315	https://www.r4.com/articulos-y-analisis/valores/telefonica-adjudicaciones-programa-unico	1891	7	2025-11-05 08:37:46.846785	\N	\N	\N	f	\N	t	4	f
4316	https://www.r4.com/articulos-y-analisis/valores/telefonica-se-rompe-el-pacto-para-dar-entrada-a-socios-en-la-division-de-fibra-de-peru	1891	7	2025-11-05 08:37:49.171278	\N	\N	\N	f	\N	t	4	f
4317	https://www.r4.com/articulos-y-analisis/valores/telefonica-el-consejo-de-ministros-autoriza-a-stc-aumentar-su-participacion-del-4-9-al-9-9	1891	7	2025-11-05 08:37:51.428504	\N	\N	\N	f	\N	t	4	f
4318	https://www.r4.com/articulos-y-analisis/valores/telefonica-cumplimiento-de-la-guia-crecimiento-ingresos-24e-comprometido-aunque-generacion-de-caja-muy-positiva-p-o-4-6-eur-mantener	1891	7	2025-11-05 08:37:52.611904	\N	\N	\N	f	\N	t	4	f
4319	https://www.r4.com/articulos-y-analisis/valores/telefonica-ebitda-subyacente-mejor-de-lo-previsto-resultados-extraordinarios-negativos-mantiene-la-guia-2024e-aunque-cumplimiento-de-crecimiento-de-ingresos-comprometido-p-o-4-6-eur-mantener	1891	7	2025-11-05 08:37:53.853988	\N	\N	\N	f	\N	t	4	f
4320	https://www.r4.com/articulos-y-analisis/valores/telefonica-vmedo2-reino-unido-vende-una-participacion-en-cornerstone-telecommunications	1891	7	2025-11-05 08:37:55.035014	\N	\N	\N	f	\N	t	4	f
4321	https://www.r4.com/articulos-y-analisis/valores/telefonica-la-depreciacion-de-las-divisas-latam-podria-complicar-el-cumplimiento-de-algunos-parametros-de-la-guia-2024e-p-o-4-6-eur-mantener	1891	7	2025-11-05 08:37:56.226549	\N	\N	\N	f	\N	t	4	f
4322	https://www.r4.com/articulos-y-analisis/valores/telefonica-conferencia-2t-24-en-linea-para-cumplir-con-la-guia-2024e-p-o-4-6-eur-mantener	1891	7	2025-11-05 08:37:58.606304	\N	\N	\N	f	\N	t	4	f
4323	https://www.r4.com/articulos-y-analisis/valores/telefonica-supera-a-nivel-operativo-la-generacion-de-caja-se-acelera-apoyada-en-el-menor-capex-mantiene-la-guia-2024e-conferencia-10h-p-o-4-6-eur-mantener	1891	7	2025-11-05 08:38:00.981301	\N	\N	\N	f	\N	t	4	f
4324	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0178430E18/5	1891	7	2025-11-05 08:38:02.13804	\N	\N	\N	f	\N	t	4	f
4325	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/la-contraccion-suave-pero-prolongada-como-escenario-alternativo-al-aterrizaje-suave	1892	7	2025-11-05 08:38:04.411881	\N	\N	\N	f	\N	t	4	f
4326	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU0353647737&DIVI=EUR&CBR=	1894	7	2025-11-05 08:38:05.613661	\N	\N	\N	f	\N	t	4	f
4327	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU0613075240&DIVI=EUR&CBR=	1894	7	2025-11-05 08:38:06.775932	\N	\N	\N	f	\N	t	4	f
4328	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=ES0176954008&DIVI=EUR&CBR=	1894	7	2025-11-05 08:38:07.957379	\N	\N	\N	f	\N	t	4	f
4329	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=ES0173130016&DIVI=EUR&CBR=	1895	7	2025-11-05 08:38:09.154346	\N	\N	\N	f	\N	t	4	f
4330	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU1213836080&DIVI=EUR&CBR=	1895	7	2025-11-05 08:38:10.315673	\N	\N	\N	f	\N	t	4	f
4331	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=BE6213829094&DIVI=EUR&CBR=	1895	7	2025-11-05 08:38:11.5045	\N	\N	\N	f	\N	t	4	f
4332	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=IE00BD4GTQ32&DIVI=EUR&CBR=	1908	7	2025-11-05 08:38:12.676745	\N	\N	\N	f	\N	t	4	f
4333	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU1951225553&DIVI=EUR&CBR=	1908	7	2025-11-05 08:38:13.846966	\N	\N	\N	f	\N	t	4	f
4334	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU0326422176&DIVI=EUR&CBR=	1908	7	2025-11-05 08:38:15.041664	\N	\N	\N	f	\N	t	4	f
4335	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU0251661756&DIVI=EUR&CBR=	1910	7	2025-11-05 08:38:16.208738	\N	\N	\N	f	\N	t	4	f
4336	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU1914597502&DIVI=EUR&CBR=	1910	7	2025-11-05 08:38:17.379649	\N	\N	\N	f	\N	t	4	f
4337	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=IE00BDGV0290&DIVI=EUR&CBR=	1910	7	2025-11-05 08:38:18.534953	\N	\N	\N	f	\N	t	4	f
4338	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU0203975437&DIVI=EUR&CBR=	1910	7	2025-11-05 08:38:19.797054	\N	\N	\N	f	\N	t	4	f
4339	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU2240056015&DIVI=EUR&CBR=	1910	7	2025-11-05 08:38:20.977967	\N	\N	\N	f	\N	t	4	f
4340	https://www.r4.com/portal?TX=goto&FWD=FCH_FND&PAG=5&HOJA=2&COD_ISIN=ES0173320039&DIVI=EUR	1917	7	2025-11-05 08:38:22.207435	\N	\N	\N	f	\N	t	4	f
4341	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=ES0173320039&DIVI=EUR&CBR=	1917	7	2025-11-05 08:38:23.35485	\N	\N	\N	f	\N	t	4	f
4342	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0130960018&MKT=MCO	1918	7	2025-11-05 08:38:24.520037	\N	\N	\N	f	\N	t	4	f
4343	https://www.r4.com/articulos-y-analisis/ideas/defensivos-vs-ciclicos	1919	7	2025-11-05 08:38:25.662169	\N	\N	\N	f	\N	t	4	f
4344	https://www.r4.com/articulos-y-analisis/ideas/seleccion-30-una-estrategia-diversificada-para-invertir-en-etfs	1921	7	2025-11-05 08:38:26.819173	\N	\N	\N	f	\N	t	4	f
4345	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=ES0173130081&DIVI=EUR&CBR=	1923	7	2025-11-05 08:38:29.367985	\N	\N	\N	f	\N	t	4	f
4346	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/inversion-sostenible-que-es-y-como-funciona-acciones-fondos-y-etfs	1924	7	2025-11-05 08:38:30.546254	\N	\N	\N	f	\N	t	4	f
4347	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/oportunidad-de-inversion-en-energias-limpias	1924	7	2025-11-05 08:38:31.690078	\N	\N	\N	f	\N	t	4	f
4348	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-mundo-esta-cambiando-y-nuestra-forma-de-invertir-tambien	1924	7	2025-11-05 08:38:32.918051	\N	\N	\N	f	\N	t	4	f
4349	https://www.r4.com/articulos-y-analisis/ideas/fondos-de-inversion-inmobiliarios	1926	7	2025-11-05 08:38:35.147575	\N	\N	\N	f	\N	t	4	f
4350	https://www.r4.com/articulos-y-analisis/ideas/buffett-calidad-precio	1926	7	2025-11-05 08:38:36.343495	\N	\N	\N	f	\N	t	4	f
4351	https://www.r4.com/articulos-y-analisis/ideas/que-son-ppa	1926	7	2025-11-05 08:38:38.736583	\N	\N	\N	f	\N	t	4	f
4352	https://www.r4.com/articulos-y-analisis/ideas/acciona-entra-en-nuestra-cartera-5-grandes-y-versatil	1926	7	2025-11-05 08:38:40.001111	\N	\N	\N	f	\N	t	4	f
4353	https://www.r4.com/articulos-y-analisis/ideas/thermo-fisher	1926	7	2025-11-05 08:38:41.218316	\N	\N	\N	f	\N	t	4	f
4354	https://www.r4.com/articulos-y-analisis/ideas/nextil-una-oportunidad-de-inversion	1926	7	2025-11-05 08:38:42.411604	\N	\N	\N	f	\N	t	4	f
4355	https://www.r4.com/articulos-y-analisis/ideas/opa-bbva-sabadell	1926	7	2025-11-05 08:38:43.648604	\N	\N	\N	f	\N	t	4	f
4356	https://www.r4.com/articulos-y-analisis/ideas/potencial-hoy-empresas-del-manana	1926	7	2025-11-05 08:38:45.91974	\N	\N	\N	f	\N	t	4	f
4357	https://www.r4.com/articulos-y-analisis/ideas/acerinox-y-su-impulso-global-hacia-un-2025-prometedor	1926	7	2025-11-05 08:38:48.158749	\N	\N	\N	f	\N	t	4	f
4358	https://www.r4.com/articulos-y-analisis/ideas/7	1926	7	2025-11-05 08:38:49.358551	\N	\N	\N	f	\N	t	4	f
4359	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/vieja-y-nueva-alquimia-financiera-chocan-en-un-inusual-inicio-de-ano	1935	7	2025-11-05 08:38:50.576407	\N	\N	\N	f	\N	t	4	f
4360	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/trump-da-la-espalda-a-wall-street-pero-podra-darsela-a-main-street	1936	7	2025-11-05 08:38:52.872701	\N	\N	\N	f	\N	t	4	f
4664	https://www.r4.com/articulos-y-analisis/fondos/8	4467	8	2025-11-05 08:47:49.895119	\N	\N	\N	f	\N	t	4	f
4361	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/quien-tiene-las-cartas-la-estanflacion-puede-condicionar-el-dia-de-la-liberacion	1937	7	2025-11-05 08:38:55.279762	\N	\N	\N	f	\N	t	4	f
4362	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/la-novedad-es-que-ya-no-importa-la-recesion-pero-y-la-estanflacion	1937	7	2025-11-05 08:38:57.487017	\N	\N	\N	f	\N	t	4	f
4363	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/trump-y-las-bolsas-una-relacion-complicada-entre-la-recesion-y-la-edad-de-oro	1937	7	2025-11-05 08:38:58.68399	\N	\N	\N	f	\N	t	4	f
4364	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/incertidumbre-o-detox-se-cae-el-trump-trade-a-ambos-lados-del-atlantico	1937	7	2025-11-05 08:39:00.888486	\N	\N	\N	f	\N	t	4	f
4365	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/a-la-espera-de-la-prima-de-riesgo-politica-las-bolsas-europeas-golpean-de-nuevo	1937	7	2025-11-05 08:39:03.142988	\N	\N	\N	f	\N	t	4	f
4366	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/tiene-america-tambien-su-problema-dentro	1937	7	2025-11-05 08:39:04.381123	\N	\N	\N	f	\N	t	4	f
4367	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/las-bolsas-europeas-no-comparten-los-temores-sobre-trump	1937	7	2025-11-05 08:39:06.517006	\N	\N	\N	f	\N	t	4	f
4368	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/febrero-empieza-como-termino-enero-pero-con-mas-cautela	1937	7	2025-11-05 08:39:07.706521	\N	\N	\N	f	\N	t	4	f
4369	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/enero-nos-prepara-para-un-2025-de-sorpresas-inesperadas	1937	7	2025-11-05 08:39:08.925159	\N	\N	\N	f	\N	t	4	f
4370	https://www.r4.com/columnas-de-autores/vive-la-pasion-de-los-mercados/5	1937	7	2025-11-05 08:39:10.158376	\N	\N	\N	f	\N	t	4	f
4371	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-inditex-y-oracle-vuelve-el-dinero-a-estados-unidos	1938	7	2025-11-05 08:39:11.367348	\N	\N	\N	f	\N	t	4	f
4372	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-activo-sin-riesgo-no-existe	1946	7	2025-11-05 08:39:12.6222	\N	\N	\N	f	\N	t	4	f
4373	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/inevitable-dependencia-mutua-entre-china-y-estados-unidos	1946	7	2025-11-05 08:39:14.783232	\N	\N	\N	f	\N	t	4	f
4374	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/seudo-arancel-financiero-en-forma-de-impuesto-represalia	1946	7	2025-11-05 08:39:15.983362	\N	\N	\N	f	\N	t	4	f
4375	https://www.r4.com/articulos-y-analisis/mercados/7	1946	7	2025-11-05 08:39:18.261621	\N	\N	\N	f	\N	t	4	f
4376	https://www.r4.com/articulos-y-analisis/informes-de-analisis/incertidumbre-ante-los-aranceles-de-trump	1961	7	2025-11-05 08:39:19.478702	\N	\N	\N	f	\N	t	4	f
4377	https://www.r4.com/articulos-y-analisis/valores/telefonica-previo-4t-24-la-depreciacion-de-las-divisas-latam-podria-complicar-el-cumplimiento-de-algunos-parametros-de-la-guia-2024e	1966	7	2025-11-05 08:39:21.754369	\N	\N	\N	f	\N	t	4	f
4378	https://www.r4.com/articulos-y-analisis/valores/repsol-4t24-incrementando-la-visibilidad-sobre-sus-objetivos-del-pe-24-27	1966	7	2025-11-05 08:39:23.928221	\N	\N	\N	f	\N	t	4	f
4379	https://www.r4.com/articulos-y-analisis/valores/repsol-4t24-mejorando-estimaciones-y-guia-de-caja-operativa-por-encima-de-las-expectativas	1966	7	2025-11-05 08:39:25.138298	\N	\N	\N	f	\N	t	4	f
4380	https://www.r4.com/articulos-y-analisis/valores/repsol-previo-4t24-la-atencion-estara-en-la-guia-para-2025-y-nuevas-recompras-de-acciones	1966	7	2025-11-05 08:39:26.394165	\N	\N	\N	f	\N	t	4	f
4381	https://www.r4.com/articulos-y-analisis/valores/repsol-entrada-en-el-negocio-de-centros-de-datos	1966	7	2025-11-05 08:39:28.604332	\N	\N	\N	f	\N	t	4	f
4382	https://www.r4.com/articulos-y-analisis/valores/repsol-trading-statement-del-cuarto-trimestre-2024	1966	7	2025-11-05 08:39:30.719302	\N	\N	\N	f	\N	t	4	f
4383	https://www.r4.com/articulos-y-analisis/valores/repsol-elevada-retribucion-al-accionista-y-valoracion-atractiva	1966	7	2025-11-05 08:39:32.933453	\N	\N	\N	f	\N	t	4	f
4384	https://www.r4.com/articulos-y-analisis/valores/repsol-venta-negocio-en-colombia-por-500-millones-de-euros	1966	7	2025-11-05 08:39:34.120231	\N	\N	\N	f	\N	t	4	f
4385	https://www.r4.com/articulos-y-analisis/valores/repsol-3t24-generando-caja-en-un-trimestre-complicado	1966	7	2025-11-05 08:39:35.317167	\N	\N	\N	f	\N	t	4	f
4386	https://www.r4.com/articulos-y-analisis/valores/repsol-proyectos-renovables-en-nueva-york	1966	7	2025-11-05 08:39:36.498329	\N	\N	\N	f	\N	t	4	f
4387	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0173516115/4	1966	7	2025-11-05 08:39:37.676074	\N	\N	\N	f	\N	t	4	f
4388	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-contrato-con-saudi-aramco	1984	7	2025-11-05 08:39:39.73896	\N	\N	\N	f	\N	t	4	f
4389	https://www.r4.com/articulos-y-analisis/valores/tre-contrato-para-ciclo-combinado-de-hidrogeno	1984	7	2025-11-05 08:39:41.968529	\N	\N	\N	f	\N	t	4	f
4390	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-resumen-primer-dia-del-capital-markets-day	1984	7	2025-11-05 08:39:44.279227	\N	\N	\N	f	\N	t	4	f
4391	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-nuevo-plan-estrategico-con-espectaculares-objetivos-muy-por-encima-de-las-estimaciones-del-consenso-del-mercado	1984	7	2025-11-05 08:39:45.479194	\N	\N	\N	f	\N	t	4	f
4392	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-1t24-mejores-de-lo-esperado-por-mayor-actividad-y-confirmando-los-margenes	1984	7	2025-11-05 08:39:46.65568	\N	\N	\N	f	\N	t	4	f
4393	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-previo-1t24-confirmacion-de-margenes	1984	7	2025-11-05 08:39:47.894618	\N	\N	\N	f	\N	t	4	f
4394	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-resultados-2023-cumpliendo-el-guidance-de-margenes	1984	7	2025-11-05 08:39:50.108596	\N	\N	\N	f	\N	t	4	f
4395	https://www.r4.com/articulos-y-analisis/valores/tecnicas-reunidas-2023-continua-mejora-de-margenes	1984	7	2025-11-05 08:39:52.394821	\N	\N	\N	f	\N	t	4	f
4396	https://www.r4.com/articulos-y-analisis/valores/caixabank-aplicacion-de-colchon-de-capital-contra-riesgo-sistemico-en-portugal	2010	7	2025-11-05 08:39:54.873228	\N	\N	\N	f	\N	t	4	f
4397	https://www.r4.com/articulos-y-analisis/valores/caixabank-resultados-1t24-mejoran-guia-de-margen-de-intereses-y-rote-para-el-ano-recomendacion-en-revision-p-o-4-3-eur-acc	2010	7	2025-11-05 08:39:56.96878	\N	\N	\N	f	\N	t	4	f
4398	https://www.r4.com/articulos-y-analisis/valores/caixabank-4t23-cambio-en-la-politica-de-dividendos-guias-2024-muy-alineadas-con-2023	2010	7	2025-11-05 08:39:59.369789	\N	\N	\N	f	\N	t	4	f
4399	https://www.r4.com/articulos-y-analisis/valores/sector-financiero-la-audiencia-nacional-tumba-la-multa-impuesta-por-la-cnmc-a-santander-bbva-caixabank-y-sabadell-por-pactar-precios	2010	7	2025-11-05 08:40:00.562825	\N	\N	\N	f	\N	t	4	f
4400	https://www.r4.com/articulos-y-analisis/informes-de-analisis/bce-y-cumbre-europea-de-defensa-protagonistas-de-la-jornada	2012	7	2025-11-05 08:40:02.798262	\N	\N	\N	f	\N	t	4	f
4401	https://www.r4.com/articulos-y-analisis/valores/santander-1t24-fortaleza-en-los-ingresos-recurrentes-cifras-alineadas-con-los-objetivos-sobreponderar-p-o-5-6-eur-acc	2019	7	2025-11-05 08:40:04.957344	\N	\N	\N	f	\N	t	4	f
4402	https://www.r4.com/articulos-y-analisis/valores/santander-4t23-conferencia-de-resultados-guias-2024-alcanzables-menor-impacto-de-basilea-iii-en-capital-sobreponderar-p-o-5-6-eur-acc	2019	7	2025-11-05 08:40:06.152824	\N	\N	\N	f	\N	t	4	f
4403	https://www.r4.com/articulos-y-analisis/valores/santander-resultados-4t23-cumpliendo-las-guias-de-2023-apoyado-por-la-solidez-operativa-y-control-de-costes	2019	7	2025-11-05 08:40:08.459232	\N	\N	\N	f	\N	t	4	f
4404	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-la-jga-aprueba-la-opa-sobre-aedas	2022	7	2025-11-05 08:40:09.690443	\N	\N	\N	f	\N	t	4	f
4405	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-lanza-una-opa-voluntaria-sobre-aedas-homes-a-24-485-eur-accion-en-efectivo-recomendamos-vender-a-mercado-aedas-homes	2022	7	2025-11-05 08:40:11.853083	\N	\N	\N	f	\N	t	4	f
4406	https://www.r4.com/articulos-y-analisis/valores/aedas-homes-fitch-mantiene-el-rating-en-bb	2022	7	2025-11-05 08:40:13.161762	\N	\N	\N	f	\N	t	4	f
4407	https://www.r4.com/articulos-y-analisis/valores/aedas-homes-2024-buenos-resultados-dividendo-por-encima-de-lo-esperado-pero-cotizacion-supeditada-a-noticias-de-angulo-corporativo	2022	7	2025-11-05 08:40:15.371987	\N	\N	\N	f	\N	t	4	f
4408	https://www.r4.com/articulos-y-analisis/valores/aedas-homes-previo-4t24-25-2024-25-solido-trimestre-ya-descontado	2022	7	2025-11-05 08:40:16.582569	\N	\N	\N	f	\N	t	4	f
4409	https://www.r4.com/articulos-y-analisis/valores/aedas-homes-nuevo-avance-de-resultados-del-ejercicio-2024-2025-cumpliendo-objetivos-y-con-cifras-financieras-por-encima-de-nuestras-estimaciones	2022	7	2025-11-05 08:40:18.815503	\N	\N	\N	f	\N	t	4	f
4410	https://www.r4.com/articulos-y-analisis/valores/aedas-homes-angulo-corporativo-y-expectativa-de-dividendos-sostienen-cotizacion	2022	7	2025-11-05 08:40:20.03929	\N	\N	\N	f	\N	t	4	f
4411	https://www.r4.com/articulos-y-analisis/valores/aedas-homes-avanza-preventas-record-en-2024-25-y-el-cumplimiento-de-objetivos-anuales	2022	7	2025-11-05 08:40:22.295714	\N	\N	\N	f	\N	t	4	f
4412	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105287009/2	2022	7	2025-11-05 08:40:23.465779	\N	\N	\N	f	\N	t	4	f
4413	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-realiza-una-emision-adicional-de-100-millones-de-euros-de-sus-bonos-verdes-al-5-875	2023	7	2025-11-05 08:40:25.536849	\N	\N	\N	f	\N	t	4	f
4414	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-la-cnmc-autoriza-la-opa-sobre-aedas	2023	7	2025-11-05 08:40:27.840256	\N	\N	\N	f	\N	t	4	f
4415	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-creando-la-mayor-promotora-de-espana	2023	7	2025-11-05 08:40:29.994283	\N	\N	\N	f	\N	t	4	f
4416	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-1s25-semestre-de-transicion-a-la-espera-de-un-fuerte-2s25	2023	7	2025-11-05 08:40:31.187775	\N	\N	\N	f	\N	t	4	f
4417	https://www.r4.com/articulos-y-analisis/valores/aedas-homes-resultados-1t25-26-sin-impacto-ante-la-opa-lanzada-por-neinor	2023	7	2025-11-05 08:40:33.325156	\N	\N	\N	f	\N	t	4	f
4418	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-anuncia-un-acuerdo-llave-en-mano-de-45-mln-eur-para-el-desarrollo-de-vivienda-asequible-en-alquiler-en-barcelona	2023	7	2025-11-05 08:40:34.562779	\N	\N	\N	f	\N	t	4	f
4419	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-previo-1s25-bajos-niveles-de-entregas-con-solidez-comercial-y-visibilidad	2023	7	2025-11-05 08:40:35.782357	\N	\N	\N	f	\N	t	4	f
4420	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-anuncia-aumento-de-capital-por-el-20-del-capital-social	2023	7	2025-11-05 08:40:37.957037	\N	\N	\N	f	\N	t	4	f
4421	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105251005/2	2023	7	2025-11-05 08:40:39.139342	\N	\N	\N	f	\N	t	4	f
4422	https://www.r4.com/articulos-y-analisis/informes-de-analisis/excesivo-optimismo-europa-vs-excesivo-pesimismo-ee-uu	2028	7	2025-11-05 08:40:41.152391	\N	\N	\N	f	\N	t	4	f
4423	https://www.r4.com/articulos-y-analisis/id/871218?utm_source=bdd_prensa&utm_medium=e-mail&utm_campaign=enviosprensa	2028	7	2025-11-05 08:40:42.376925	\N	\N	\N	f	\N	t	4	f
4424	https://www.r4.com/articulos-y-analisis/informes-de-analisis/powell-calma-en-cierta-medida-los-temores-del-mercado	2029	7	2025-11-05 08:40:48.723158	\N	\N	\N	f	\N	t	4	f
4425	https://www.r4.com/articulos-y-analisis/valores/isur-4t23-las-ventas-de-suelo-compensan-retrasos-en-entregas	2040	7	2025-11-05 08:40:50.968172	\N	\N	\N	f	\N	t	4	f
4426	https://www.r4.com/articulos-y-analisis/valores/inmobiliaria-del-sur-previo-4t23-concentracion-de-entregas	2040	7	2025-11-05 08:40:52.218428	\N	\N	\N	f	\N	t	4	f
4427	https://www.r4.com/articulos-y-analisis/valores/ence-previo-2t24-precios-elevados-y-cash-cost-normalizando-para-financiar-crecimiento-y-dividendos	2056	7	2025-11-05 08:40:54.447368	\N	\N	\N	f	\N	t	4	f
4428	https://www.r4.com/articulos-y-analisis/valores/ence-recibe-la-nota-mas-alta-esg-del-sector-por-parte-de-sustainalytics	2056	7	2025-11-05 08:40:56.78343	\N	\N	\N	f	\N	t	4	f
4429	https://www.r4.com/articulos-y-analisis/valores/paper-pills-4t23-follow-the-leader	2056	7	2025-11-05 08:40:58.95566	\N	\N	\N	f	\N	t	4	f
4430	https://www.r4.com/articulos-y-analisis/valores/ence-2023-contexto-favorable-para-el-exigente-capital-allocation	2056	7	2025-11-05 08:41:01.290166	\N	\N	\N	f	\N	t	4	f
4431	https://www.r4.com/articulos-y-analisis/valores/ence-4t23-precios-al-alza-y-cash-cost-a-la-baja-confirman-punto-de-inflexion	2056	7	2025-11-05 08:41:03.40477	\N	\N	\N	f	\N	t	4	f
4432	https://www.r4.com/articulos-y-analisis/valores/ence-previo-4t23-a-la-espera-de-una-recuperacion-que-permita-financiar-los-proyectos-de-crecimiento	2056	7	2025-11-05 08:41:05.607035	\N	\N	\N	f	\N	t	4	f
4433	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0109260531	2058	7	2025-11-05 08:41:06.814464	\N	\N	\N	f	\N	t	4	f
4434	https://www.r4.com/articulos-y-analisis/valores/indra-prosigue-su-favorable-evolucion-pendientes-de-noticias-corporativas-otro-catalizador-p-o-24-2-eur-sobreponderar	2068	7	2025-11-05 08:41:08.071979	\N	\N	\N	f	\N	t	4	f
4435	https://www.r4.com/articulos-y-analisis/valores/indra-resultados-2t-24-por-debajo-de-lo-previsto-a-nivel-operativo-aunque-mejoran-la-guia-2024e-conferencia-9-00h-p-o-24-2-eur-sobreponderar	2068	7	2025-11-05 08:41:10.217025	\N	\N	\N	f	\N	t	4	f
4436	https://www.r4.com/articulos-y-analisis/valores/indra-previo-2t-24-se-mantiene-la-buena-evolucion-seguimos-pendientes-de-las-noticias-corporativas-otro-catalizador-p-o-24-2-eur-sobreponderar	2068	7	2025-11-05 08:41:12.542039	\N	\N	\N	f	\N	t	4	f
4437	https://www.r4.com/articulos-y-analisis/valores/indra-segun-prensa-indra-ha-contratado-a-citi-y-az-capital-para-el-proceso-de-venta-de-minsait	2068	7	2025-11-05 08:41:13.747636	\N	\N	\N	f	\N	t	4	f
4438	https://www.r4.com/articulos-y-analisis/valores/indra-resultados-1t-24-superan-ampliamente-las-previsiones-gran-inicio-de-cara-al-cumplimiento-mejora-de-objetivos-2024e-p-o-24-2-eur-sobreponderar	2068	7	2025-11-05 08:41:14.970408	\N	\N	\N	f	\N	t	4	f
4439	https://www.r4.com/articulos-y-analisis/valores/indra-previo-1t-24-se-mantiene-la-buena-evolucion-noticias-corporativas-p-o-24-2-eur-sobreponderar	2068	7	2025-11-05 08:41:16.160256	\N	\N	\N	f	\N	t	4	f
4440	https://www.r4.com/articulos-y-analisis/valores/indra-mas-defensa-para-un-buen-ataque-p-o-24-2-eur-antes-18-6-eur-sobreponderar	2068	7	2025-11-05 08:41:17.372212	\N	\N	\N	f	\N	t	4	f
4441	https://www.r4.com/articulos-y-analisis/valores/indra-resultados-4t-23-superan-previsiones-ampliamente-guia-2024e-mejor-de-lo-previsto-p-o-18-6-eur-sobreponderar	2068	7	2025-11-05 08:41:18.62485	\N	\N	\N	f	\N	t	4	f
4442	https://www.r4.com/articulos-y-analisis/valores/sector-tecnologico-el-gobierno-crea-una-sepi-digital	2068	7	2025-11-05 08:41:19.838347	\N	\N	\N	f	\N	t	4	f
4443	https://www.r4.com/articulos-y-analisis/valores/indra-previo-4t-23-se-mantiene-la-buena-evolucion-con-la-vista-puesta-en-el-dia-del-inversor-6-de-marzo-p-o-18-6-eur-sobreponderar	2068	7	2025-11-05 08:41:22.092866	\N	\N	\N	f	\N	t	4	f
4444	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0105546008	2069	7	2025-11-05 08:41:24.458156	\N	\N	\N	f	\N	t	4	f
4445	https://www.r4.com/articulos-y-analisis/valores/7	2072	7	2025-11-05 08:41:26.581429	\N	\N	\N	f	\N	t	4	f
4446	https://www.r4.com/articulos-y-analisis/tecnico/claro-cambio-a-mejor-en-rovi	2085	7	2025-11-05 08:41:28.619729	\N	\N	\N	f	\N	t	4	f
4447	https://www.r4.com/articulos-y-analisis/tecnico/riot-platforms-otro-cripto-proxy-con-mejor-riesgo-que-mara-holdings	2085	7	2025-11-05 08:41:30.765393	\N	\N	\N	f	\N	t	4	f
4448	https://www.r4.com/articulos-y-analisis/tecnico/russell-semiconductores-y-cripto-ultimos-motores-por-detonar	2085	7	2025-11-05 08:41:32.921532	\N	\N	\N	f	\N	t	4	f
4449	https://www.r4.com/articulos-y-analisis/tecnico/santander-y-la-diferencia-de-si-inviertes-a-medio-o-a-largo-plazo	2085	7	2025-11-05 08:41:34.205571	\N	\N	\N	f	\N	t	4	f
4450	https://www.r4.com/articulos-y-analisis/tecnico/inditex-boceto-escenario-esperado-y-niveles-clave	2085	7	2025-11-05 08:41:36.437527	\N	\N	\N	f	\N	t	4	f
4451	https://www.r4.com/articulos-y-analisis/tecnico/mara-holdings-un-proxy-de-los-ciclos-del-bitcoin	2085	7	2025-11-05 08:41:38.758894	\N	\N	\N	f	\N	t	4	f
4452	https://www.r4.com/articulos-y-analisis/tecnico/s-p-500-tiempo-maximo-sin-un-drawdown-igual-o-superior-al-5	2085	7	2025-11-05 08:41:40.880424	\N	\N	\N	f	\N	t	4	f
4453	https://www.r4.com/articulos-y-analisis/tecnico/delivery-hero-detalles-de-cambio-en-el-medio-plazo-y-senal-compra-de-corto-plazo	2085	7	2025-11-05 08:41:43.167245	\N	\N	\N	f	\N	t	4	f
4454	https://www.r4.com/articulos-y-analisis/tecnico/puig-brands-la-paciencia-se-paga	2085	7	2025-11-05 08:41:44.351036	\N	\N	\N	f	\N	t	4	f
4455	https://www.r4.com/articulos-y-analisis/tecnico/s-p500-los-minimos-de-agosto-ahora-colchon-brillan-las-small-cap-americanas	2085	7	2025-11-05 08:41:46.664351	\N	\N	\N	f	\N	t	4	f
4456	https://www.r4.com/articulos-y-analisis/tecnico/7	2085	7	2025-11-05 08:41:48.889146	\N	\N	\N	f	\N	t	4	f
4457	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-pegasus-a-cierre-de-junio-de-2025	4182	7	2025-11-05 08:41:50.178941	\N	\N	\N	f	\N	t	4	f
4458	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-global-dynamic-fi-a-cierre-de-junio-de-2025	4182	7	2025-11-05 08:41:52.37884	\N	\N	\N	f	\N	t	4	f
4459	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-alpha-global-a-cierre-de-junio-de-2025	4182	7	2025-11-05 08:41:53.555892	\N	\N	\N	f	\N	t	4	f
4460	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-megatendencias-medio-ambiente-a-cierre-de-junio-de-2025	4182	7	2025-11-05 08:41:54.822068	\N	\N	\N	f	\N	t	4	f
4461	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-megatendencias-salud-a-cierre-de-junio-de-2025	4182	7	2025-11-05 08:41:56.023416	\N	\N	\N	f	\N	t	4	f
4462	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-eeuu-acciones-fi-a-cierre-de-junio-de-2025	4182	7	2025-11-05 08:41:58.725138	\N	\N	\N	f	\N	t	4	f
4463	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-megatendencias-consumo-a-cierre-de-junio-de-2025	4182	7	2025-11-05 08:41:59.95101	\N	\N	\N	f	\N	t	4	f
4464	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-renta-fija-mixto-a-cierre-de-junio-de-2025	4182	7	2025-11-05 08:42:01.166903	\N	\N	\N	f	\N	t	4	f
4465	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-latinoamerica-a-cierre-de-junio-de-2025	4182	7	2025-11-05 08:42:03.541295	\N	\N	\N	f	\N	t	4	f
4466	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-nexus-a-cierre-de-junio-de-2025	4182	7	2025-11-05 08:42:05.723342	\N	\N	\N	f	\N	t	4	f
4467	https://www.r4.com/articulos-y-analisis/fondos/7	4182	7	2025-11-05 08:42:08.048872	\N	\N	\N	f	\N	t	4	f
4468	https://www.r4.com/politica-privacidad	4183	7	2025-11-05 08:42:10.027511	\N	\N	\N	f	\N	t	4	f
4470	https://www.r4.com/aviso-legal	4183	7	2025-11-05 08:42:12.881704	\N	\N	\N	f	\N	t	4	f
4471	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/las-bolsas-ignoran-completamente-a-los-bonos	4185	7	2025-11-05 08:42:14.369115	\N	\N	\N	f	\N	t	4	f
4472	https://www.r4.com/academiar4/formulario-cursos?id=3636	4207	7	2025-11-05 08:42:16.596821	\N	\N	\N	f	\N	t	4	f
4473	https://www.r4.com/academiar4/formulario-cursos?id=3638	4207	7	2025-11-05 08:42:18.796302	\N	\N	\N	f	\N	t	4	f
4474	https://www.r4.com/academiar4/formulario-cursos?id=3640	4207	7	2025-11-05 08:42:21.000156	\N	\N	\N	f	\N	t	4	f
4475	https://www.r4.com/academiar4/formulario-cursos?id=3641	4207	7	2025-11-05 08:42:23.43735	\N	\N	\N	f	\N	t	4	f
4476	https://www.r4.com/academiar4/formulario-cursos?id=3639	4207	7	2025-11-05 08:42:25.701748	\N	\N	\N	f	\N	t	4	f
4477	https://www.r4.com/academiar4/formulario-cursos?id=3637	4207	7	2025-11-05 08:42:27.890307	\N	\N	\N	f	\N	t	4	f
4478	https://www.r4.com/academiar4/formulario-cursos?id=3642	4207	7	2025-11-05 08:42:30.204795	\N	\N	\N	f	\N	t	4	f
4479	https://www.r4.com/academiar4/formulario-cursos?id=3643	4207	7	2025-11-05 08:42:32.44674	\N	\N	\N	f	\N	t	4	f
4480	http://r4.com/planes-de-pensiones	4209	7	2025-11-05 08:42:34.567654	\N	\N	\N	f	\N	t	4	f
4481	https://www.r4.com/planes-de-pensiones/planifica-tu-futuro	4209	7	2025-11-05 08:42:36.15042	\N	\N	\N	f	\N	t	4	f
4482	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-banco-pone-en-marcha-renta-4-digital-assets-la-nueva-unidad-centrada-en-activos-digitales-y-tecnologia-blockchain	4232	7	2025-11-05 08:42:37.34666	\N	\N	\N	f	\N	t	4	f
4483	https://www.r4.com/fondos-de-inversion/fondos/ES0173053028	4232	7	2025-11-05 08:42:38.531874	\N	\N	\N	f	\N	t	4	f
4484	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-banco-obtiene-un-beneficio-neto-en-el-2023-de-26-6-millones-de-euros-un-21-9-mas-que-en-el-ano-anterior	4235	7	2025-11-05 08:42:39.815126	\N	\N	\N	f	\N	t	4	f
4485	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-banco-se-une-a-terram-capital-para-invertir-en-deuda-alternativa-asset-backed	4235	7	2025-11-05 08:42:40.979222	\N	\N	\N	f	\N	t	4	f
4486	https://www.r4.com/articulos-y-analisis/noticias-renta4/renta-4-banco-renueva-la-operativa-de-letras-del-tesoro-para-hacerla-mas-eficiente-e-inmediata	4235	7	2025-11-05 08:42:42.223892	\N	\N	\N	f	\N	t	4	f
4487	https://www.r4.com/articulos-y-analisis/valores/banco-sabadell-manteniendo-el-tipo-en-rentabilidad-como-defensa-a-la-opa	4244	8	2025-11-05 08:42:43.434368	\N	\N	\N	f	\N	t	4	f
4488	https://www.r4.com/articulos-y-analisis/valores/sabadell-3t24-solidez-del-margen-apoyado-por-volumenes-mejoran-guia-de-coste-de-riesgo-sobreponderar-p-o-2-16-eur-acc	4244	8	2025-11-05 08:42:44.664033	\N	\N	\N	f	\N	t	4	f
4489	https://www.r4.com/articulos-y-analisis/valores/sabadell-resultados-2t24-los-volumenes-apoyan-la-mejora-de-guias-sobreponderar-p-o-2-16-eur-acc	4244	8	2025-11-05 08:42:45.871723	\N	\N	\N	f	\N	t	4	f
4490	https://www.r4.com/articulos-y-analisis/valores/sabadell-fitch-mejora-el-rating-de-largo-plazo-de-sabadell	4244	8	2025-11-05 08:42:48.21694	\N	\N	\N	f	\N	t	4	f
4491	https://www.r4.com/articulos-y-analisis/valores/sabadell-suspende-temporalmente-el-programa-de-recompra-de-acciones-que-estaba-en-curso	4244	8	2025-11-05 08:42:49.477688	\N	\N	\N	f	\N	t	4	f
4492	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0113860A34/4	4244	8	2025-11-05 08:42:51.700907	\N	\N	\N	f	\N	t	4	f
4493	https://www.r4.com/articulos-y-analisis/valores/bankinter-resultados-1t24-dinamicas-alineadas-con-las-guias-sobreponderar-p-o-7-9-eur-acc	4252	8	2025-11-05 08:42:53.759592	\N	\N	\N	f	\N	t	4	f
4494	https://www.r4.com/articulos-y-analisis/valores/bankinter-preparados-para-la-bajada-de-tipos-sobreponderar-p-o-7-9-eur-acc-vs-6-91-eur-anterior	4252	8	2025-11-05 08:42:54.976684	\N	\N	\N	f	\N	t	4	f
4495	https://www.r4.com/articulos-y-analisis/valores/bankinter-resultados-4t23-cifras-por-debajo-de-las-estimaciones-atencion-a-las-guias-sobrepondear-p-o-7-77-eur-acc	4252	8	2025-11-05 08:42:57.183326	\N	\N	\N	f	\N	t	4	f
4496	https://www.r4.com/articulos-y-analisis/valores/bbva-solidez-operativa-y-menos-dudas-en-turquia-apoyan-la-valoracion-mantener-p-o-10-62-eur-acc-8-9-eur-acc	4261	8	2025-11-05 08:42:59.581158	\N	\N	\N	f	\N	t	4	f
4497	https://www.r4.com/articulos-y-analisis/valores/bbva-conclusiones-conferencia-de-resultados-4t23-se-mantendra-el-crecimiento-en-2024-del-beneficio-neto-apoyando-una-solida-politica-de-dividendos-mantener-p-o-8-51-eur-acc	4261	8	2025-11-05 08:43:01.912619	\N	\N	\N	f	\N	t	4	f
4498	https://www.r4.com/articulos-y-analisis/valores/bbva-resultados-4t23-cifras-mixtas-dudas-en-espana-mantener-p-o-8-51-eur-acc	4261	8	2025-11-05 08:43:04.050576	\N	\N	\N	f	\N	t	4	f
4499	https://www.r4.com/articulos-y-analisis/valores/colonial-ampliacion-de-capital-de-622-millones-de-euros-a-suscribir-por-criteria-caixa	4301	8	2025-11-05 08:43:06.308541	\N	\N	\N	f	\N	t	4	f
4500	https://www.r4.com/articulos-y-analisis/valores/colonial-1t24-paris-impulsa-las-cifras	4301	8	2025-11-05 08:43:08.664542	\N	\N	\N	f	\N	t	4	f
4501	https://www.r4.com/articulos-y-analisis/valores/colonial-mantiene-rating-crediticio-bbb-con-perspectiva-estable-de-s-p	4301	8	2025-11-05 08:43:09.9374	\N	\N	\N	f	\N	t	4	f
4502	https://www.r4.com/articulos-y-analisis/valores/colonial-previo-1t24-otro-solido-trimestre	4301	8	2025-11-05 08:43:12.163146	\N	\N	\N	f	\N	t	4	f
4503	https://www.r4.com/articulos-y-analisis/valores/colonial-4t23-2023-la-valoracion-de-activos-empana-unos-buenos-resultados	4301	8	2025-11-05 08:43:14.328412	\N	\N	\N	f	\N	t	4	f
4504	https://www.r4.com/articulos-y-analisis/valores/metrovacesa-previo-4t23-acelerando-en-2s23	4311	8	2025-11-05 08:43:16.498176	\N	\N	\N	f	\N	t	4	f
4505	https://www.r4.com/articulos-y-analisis/valores/metrovacesa-amplia-su-acuerdo-con-vita-en-el-proyecto-oria-clesa	4311	8	2025-11-05 08:43:18.73425	\N	\N	\N	f	\N	t	4	f
4506	https://www.r4.com/articulos-y-analisis/informes-de-analisis/aranceles-china-bce-y-empleo-ee-uu-quien-da-mas	4312	8	2025-11-05 08:43:21.058625	\N	\N	\N	f	\N	t	4	f
4507	https://www.r4.com/articulos-y-analisis/id/869668?utm_source=bdd_prensa&utm_medium=e-mail&utm_campaign=enviosprensa	4313	8	2025-11-05 08:43:23.213459	\N	\N	\N	f	\N	t	4	f
4508	https://www.r4.com/articulos-y-analisis/valores/telefonica-previo-2t-24-trimestre-estable-a-nivel-operativo-con-hispam-que-continua-lastrando-esperamos-mantenimiento-de-guia-2024e-p-o-4-6-eur-mantener	4324	8	2025-11-05 08:43:29.251969	\N	\N	\N	f	\N	t	4	f
4509	https://www.r4.com/articulos-y-analisis/valores/telefonica-renovacion-del-acuerdo-de-roaming-con-digi	4324	8	2025-11-05 08:43:30.452076	\N	\N	\N	f	\N	t	4	f
4510	https://www.r4.com/articulos-y-analisis/valores/telefonica-conversaciones-para-adquirir-desktop	4324	8	2025-11-05 08:43:31.592323	\N	\N	\N	f	\N	t	4	f
4511	https://www.r4.com/articulos-y-analisis/valores/telefonica-la-sepi-anuncia-que-ya-ha-alcanzado-el-10-de-telefonica	4324	8	2025-11-05 08:43:32.803819	\N	\N	\N	f	\N	t	4	f
4512	https://www.r4.com/articulos-y-analisis/valores/telefonica-supera-a-nivel-operativo-generacion-de-caja-mas-debil-mantiene-la-guia-2024e-compras-de-la-sepi-catalizador-p-o-4-6-eur-sobreponderar	4324	8	2025-11-05 08:43:34.862515	\N	\N	\N	f	\N	t	4	f
4513	https://www.r4.com/articulos-y-analisis/valores/telefonica-previo-1t-24-buena-evolucion-en-los-principales-mercados-hispam-continua-lastrando-las-compras-de-la-sepi-principal-catalizador-p-o-4-6-eur-sobreponderar	4324	8	2025-11-05 08:43:36.017382	\N	\N	\N	f	\N	t	4	f
4514	https://www.r4.com/articulos-y-analisis/valores/telefonica-la-sepi-anuncia-que-ya-posee-un-3-de-telefonica	4324	8	2025-11-05 08:43:37.192109	\N	\N	\N	f	\N	t	4	f
4515	https://www.r4.com/articulos-y-analisis/valores/telefonica-oferta-de-exclusion-telefonica-alemania	4324	8	2025-11-05 08:43:39.418751	\N	\N	\N	f	\N	t	4	f
4516	https://www.r4.com/articulos-y-analisis/valores/conferencia-telefonica-4t-23-crecimiento-en-espana-previsto-para-2024e-p-o-4-6-eur-sobreponderar	4324	8	2025-11-05 08:43:41.878546	\N	\N	\N	f	\N	t	4	f
4517	https://www.r4.com/articulos-y-analisis/valores/telefonica-supera-en-ingresos-y-ebitda-subyacente-resultados-extraordinarios-negativos-muy-elevados-guia-2024e-muy-alineada-a-la-evolucion-prevista-hasta-2026e-p-o-4-6-eur-sobreponderar	4324	8	2025-11-05 08:43:43.052225	\N	\N	\N	f	\N	t	4	f
4518	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0178430E18/6	4324	8	2025-11-05 08:43:44.298366	\N	\N	\N	f	\N	t	4	f
4519	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/es-el-principio-de-algo-mas-profundo-los-tipos-empiezan-a-pasar-factura	4325	8	2025-11-05 08:43:46.261212	\N	\N	\N	f	\N	t	4	f
4520	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0144580Y14&MKT=MCO	4343	8	2025-11-05 08:43:47.421956	\N	\N	\N	f	\N	t	4	f
4521	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US5801351017&MKT=MMN	4343	8	2025-11-05 08:43:48.600508	\N	\N	\N	f	\N	t	4	f
4522	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0132105018&MKT=MCO	4343	8	2025-11-05 08:43:49.791234	\N	\N	\N	f	\N	t	4	f
4523	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US3453708600&MKT=MMN	4343	8	2025-11-05 08:43:50.984155	\N	\N	\N	f	\N	t	4	f
4524	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0118594417&MKT=MCO	4343	8	2025-11-05 08:43:52.125256	\N	\N	\N	f	\N	t	4	f
4525	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=GB00B10RZP78&MKT=MAS	4343	8	2025-11-05 08:43:53.288404	\N	\N	\N	f	\N	t	4	f
4526	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=LU1598757687&MKT=MCO	4343	8	2025-11-05 08:43:54.443386	\N	\N	\N	f	\N	t	4	f
4527	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US37045V1008&MKT=MMN	4343	8	2025-11-05 08:43:55.620057	\N	\N	\N	f	\N	t	4	f
4665	http://r4.com/portal?TX=goto&FWD=MAIN10	4480	8	2025-11-05 08:47:51.925281	\N	\N	\N	f	\N	t	4	f
4528	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0105563003&MKT=MCO	4343	8	2025-11-05 08:43:56.963344	\N	\N	\N	f	\N	t	4	f
4529	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US1912161007&MKT=MMN	4343	8	2025-11-05 08:43:58.373857	\N	\N	\N	f	\N	t	4	f
4530	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0173516115&MKT=MCO	4343	8	2025-11-05 08:43:59.525274	\N	\N	\N	f	\N	t	4	f
4531	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US5719032022&MKT=MMO	4343	8	2025-11-05 08:44:00.668362	\N	\N	\N	f	\N	t	4	f
4532	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0178430E18&MKT=MCO	4343	8	2025-11-05 08:44:01.836427	\N	\N	\N	f	\N	t	4	f
4533	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US7134481081&MKT=MMO	4343	8	2025-11-05 08:44:03.026399	\N	\N	\N	f	\N	t	4	f
4534	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0113900J37&MKT=MCO	4343	8	2025-11-05 08:44:04.173536	\N	\N	\N	f	\N	t	4	f
4535	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US30212P3038&MKT=MMO	4343	8	2025-11-05 08:44:05.357847	\N	\N	\N	f	\N	t	4	f
4536	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US7427181091&MKT=MMN	4343	8	2025-11-05 08:44:06.530817	\N	\N	\N	f	\N	t	4	f
4537	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0113211835&MKT=MCO	4343	8	2025-11-05 08:44:07.692886	\N	\N	\N	f	\N	t	4	f
4538	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=PA1436583006&MKT=MMN	4343	8	2025-11-05 08:44:08.853731	\N	\N	\N	f	\N	t	4	f
4539	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0130670112&MKT=MCO	4343	8	2025-11-05 08:44:10.055952	\N	\N	\N	f	\N	t	4	f
4540	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US4781601046&MKT=MMN	4343	8	2025-11-05 08:44:11.299629	\N	\N	\N	f	\N	t	4	f
4541	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US2473617023&MKT=MMN	4343	8	2025-11-05 08:44:12.472068	\N	\N	\N	f	\N	t	4	f
4542	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US66987V1098&MKT=MMN	4343	8	2025-11-05 08:44:13.686944	\N	\N	\N	f	\N	t	4	f
4543	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0105025003&MKT=MCO	4343	8	2025-11-05 08:44:14.894992	\N	\N	\N	f	\N	t	4	f
4544	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US6541061031&MKT=MMN	4343	8	2025-11-05 08:44:16.038003	\N	\N	\N	f	\N	t	4	f
4545	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US7170811035&MKT=MMN	4343	8	2025-11-05 08:44:17.177931	\N	\N	\N	f	\N	t	4	f
4546	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0139140174&MKT=MCO	4343	8	2025-11-05 08:44:18.422996	\N	\N	\N	f	\N	t	4	f
4547	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US0605051046&MKT=MMN	4343	8	2025-11-05 08:44:19.581173	\N	\N	\N	f	\N	t	4	f
4548	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0112501012&MKT=MCO	4343	8	2025-11-05 08:44:20.762147	\N	\N	\N	f	\N	t	4	f
4549	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US80105N1054&MKT=MMO	4343	8	2025-11-05 08:44:21.908183	\N	\N	\N	f	\N	t	4	f
4550	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0176252718&MKT=MCO	4343	8	2025-11-05 08:44:23.095594	\N	\N	\N	f	\N	t	4	f
4551	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US30231G1022&MKT=MMN	4343	8	2025-11-05 08:44:24.257118	\N	\N	\N	f	\N	t	4	f
4552	https://www.r4.com/articulos-y-analisis/ideas/plan-de-ahorro-ii-pias	4351	8	2025-11-05 08:44:25.405408	\N	\N	\N	f	\N	t	4	f
4553	https://www.r4.com/articulos-y-analisis/ideas/que-es-un-plan-de-ahorro-y-como-funciona-sialps	4351	8	2025-11-05 08:44:26.594314	\N	\N	\N	f	\N	t	4	f
4554	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=ES0173128002&DIVI=EUR&CBR=	4353	8	2025-11-05 08:44:27.773752	\N	\N	\N	f	\N	t	4	f
4555	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=US8835561023&MKT=MMN	4353	8	2025-11-05 08:44:28.970842	\N	\N	\N	f	\N	t	4	f
4556	https://www.r4.com/conferencias/encuentro-analisis-presencial	4354	8	2025-11-05 08:44:30.174989	\N	\N	\N	f	\N	t	4	f
4557	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0126962069&MKT=MCO	4354	8	2025-11-05 08:44:31.948116	\N	\N	\N	f	\N	t	4	f
4558	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0113860A34&MKT=MCO	4355	8	2025-11-05 08:44:33.088247	\N	\N	\N	f	\N	t	4	f
4559	https://www.r4.com/portal?FWD=CNT002&amp;TX=goto&amp;TP=1&amp;DST=FND&amp;COD_ISIN=ES0173322001&amp;DIVI=EUR&amp;CBR=	4356	8	2025-11-05 08:44:34.249057	\N	\N	\N	f	\N	t	4	f
4560	https://www.r4.com/articulos-y-analisis/ideas/invertir-en-la-incertidumbre-generada-por-trump	4358	8	2025-11-05 08:44:35.785737	\N	\N	\N	f	\N	t	4	f
4561	https://www.r4.com/articulos-y-analisis/ideas/informes-trump	4358	8	2025-11-05 08:44:37.027681	\N	\N	\N	f	\N	t	4	f
4562	https://www.r4.com/articulos-y-analisis/ideas/invertir-racionalmente-en-tiempos-de-volatilidad	4358	8	2025-11-05 08:44:39.290928	\N	\N	\N	f	\N	t	4	f
4563	https://www.r4.com/articulos-y-analisis/ideas/investors-day-2025-renta-variable	4358	8	2025-11-05 08:44:41.756873	\N	\N	\N	f	\N	t	4	f
4564	https://www.r4.com/articulos-y-analisis/ideas/guerra-comercial-y-aranceles-oportunidad-en-el-sector-consumo	4358	8	2025-11-05 08:44:44.041466	\N	\N	\N	f	\N	t	4	f
4565	https://www.r4.com/articulos-y-analisis/ideas/novo-nordisk-y-eli-lilly-oportunidad-o-llegamos-tarde	4358	8	2025-11-05 08:44:45.274145	\N	\N	\N	f	\N	t	4	f
4566	https://www.r4.com/autor/ana-gomez	4358	8	2025-11-05 08:44:47.488879	\N	\N	\N	f	\N	t	4	f
4567	https://www.r4.com/articulos-y-analisis/ideas/las-companias-cotizadas-espanolas-en-el-foco	4358	8	2025-11-05 08:44:48.719043	\N	\N	\N	f	\N	t	4	f
4568	https://www.r4.com/articulos-y-analisis/ideas/iag-entra-en-nuestra-cartera-versatil	4358	8	2025-11-05 08:44:49.960887	\N	\N	\N	f	\N	t	4	f
4569	https://www.r4.com/articulos-y-analisis/ideas/8	4358	8	2025-11-05 08:44:52.293239	\N	\N	\N	f	\N	t	4	f
4570	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/validara-la-fed-la-edad-de-oro-de-las-bolsas	4370	8	2025-11-05 08:44:53.525476	\N	\N	\N	f	\N	t	4	f
4571	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/bancos-y-petroleras-impulsan-otro-trump-trade-pero-sera-como-en-el-2017	4370	8	2025-11-05 08:44:54.736518	\N	\N	\N	f	\N	t	4	f
4572	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/empieza-el-rompecabezas-del-2025-tras-un-decepcionante-fin-de-ano	4370	8	2025-11-05 08:44:56.025087	\N	\N	\N	f	\N	t	4	f
4573	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/dilemas-de-los-inversores-en-2025-en-un-entorno-de-exuberancia-racional	4370	8	2025-11-05 08:44:57.215031	\N	\N	\N	f	\N	t	4	f
4574	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/powell-pone-a-wall-street-frente-al-espejo	4370	8	2025-11-05 08:44:59.473218	\N	\N	\N	f	\N	t	4	f
4575	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/perdida-de-momentum-salvo-en-algunas-tecnologicas-y-en-el-bitcoin	4370	8	2025-11-05 08:45:01.620298	\N	\N	\N	f	\N	t	4	f
4620	https://www.r4.com/articulos-y-analisis/valores/amper-giro-a-defensa	4433	8	2025-11-05 08:46:25.280882	\N	\N	\N	f	\N	t	4	f
4576	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-rally-de-trump-se-convierte-en-everything-rally	4370	8	2025-11-05 08:45:03.771651	\N	\N	\N	f	\N	t	4	f
4577	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/luces-y-sombras-del-efecto-trump	4370	8	2025-11-05 08:45:05.02935	\N	\N	\N	f	\N	t	4	f
4578	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/todo-el-dinero-para-las-bolsas-americanas-nada-para-las-europeas	4370	8	2025-11-05 08:45:06.260298	\N	\N	\N	f	\N	t	4	f
4579	https://www.r4.com/columnas-de-autores/vive-la-pasion-de-los-mercados/6	4370	8	2025-11-05 08:45:08.488288	\N	\N	\N	f	\N	t	4	f
4580	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-bonos-del-tesoro-americano-su-deuda-nuestro-problema	4371	8	2025-11-05 08:45:09.71485	\N	\N	\N	f	\N	t	4	f
4581	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/nociones-basicas-del-mercado-de-deuda-y-por-que-estados-unidos-no-impagara-su-deuda	4375	8	2025-11-05 08:45:10.953524	\N	\N	\N	f	\N	t	4	f
4582	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-pese-a-la-remontada-de-mayo-el-nasdaq-sigue-en-negativo-en-el-ano	4375	8	2025-11-05 08:45:13.146826	\N	\N	\N	f	\N	t	4	f
4583	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/la-ia-los-aranceles-y-china-como-peligroso-adversario	4375	8	2025-11-05 08:45:14.374712	\N	\N	\N	f	\N	t	4	f
4584	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-el-bitcoin-celebra-la-one-big-beautiful-bill	4375	8	2025-11-05 08:45:16.583408	\N	\N	\N	f	\N	t	4	f
4585	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-dolar-no-tiene-competencia-pero-no-es-inmune	4375	8	2025-11-05 08:45:19.071497	\N	\N	\N	f	\N	t	4	f
4586	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-un-nuevo-record-del-vix-del-panico-a-la-calma-en-tan-solo-un-mes	4375	8	2025-11-05 08:45:20.34855	\N	\N	\N	f	\N	t	4	f
4587	https://www.r4.com/articulos-y-analisis/mercados/8	4375	8	2025-11-05 08:45:21.554479	\N	\N	\N	f	\N	t	4	f
4588	https://www.r4.com/articulos-y-analisis/informes-de-analisis/riesgo-al-dominio-tecnologico-americano-presiona-a-los-mercados	4381	8	2025-11-05 08:45:22.722512	\N	\N	\N	f	\N	t	4	f
4589	https://www.r4.com/articulos-y-analisis/valores/repsol-trading-statement-del-tercer-trimestre-2024	4387	8	2025-11-05 08:45:25.115777	\N	\N	\N	f	\N	t	4	f
4590	https://www.r4.com/articulos-y-analisis/valores/repsol-optimizando-su-cartera-de-upstream	4387	8	2025-11-05 08:45:26.272469	\N	\N	\N	f	\N	t	4	f
4591	https://www.r4.com/articulos-y-analisis/valores/repsol-2t24-avanzando-en-su-estrategia-con-unos-resultados-resilientes-y-remunerando-al-accionista	4387	8	2025-11-05 08:45:28.581965	\N	\N	\N	f	\N	t	4	f
4592	https://www.r4.com/articulos-y-analisis/valores/repsol-2t24-con-la-remuneracion-al-accionista-como-prioridad	4387	8	2025-11-05 08:45:29.791334	\N	\N	\N	f	\N	t	4	f
4593	https://www.r4.com/articulos-y-analisis/valores/repsol-pacto-con-edf-para-desarrollar-eolica-marina-en-espana-y-portugal	4387	8	2025-11-05 08:45:32.196437	\N	\N	\N	f	\N	t	4	f
4594	https://www.r4.com/articulos-y-analisis/valores/repsol-trading-statement-del-segundo-trimestre-2024	4387	8	2025-11-05 08:45:33.35176	\N	\N	\N	f	\N	t	4	f
4595	https://www.r4.com/articulos-y-analisis/valores/repsol-descubrimiento-de-petroleo-en-mexico	4387	8	2025-11-05 08:45:35.720322	\N	\N	\N	f	\N	t	4	f
4596	https://www.r4.com/articulos-y-analisis/valores/repsol-acuerdo-para-la-venta-de-una-cartera-de-activos-de-generacion-distribuida-en-francia-por-140-millones-de-euros	4387	8	2025-11-05 08:45:36.921007	\N	\N	\N	f	\N	t	4	f
4597	https://www.r4.com/articulos-y-analisis/valores/repsol-optimizacion-cartera-upstream	4387	8	2025-11-05 08:45:39.202631	\N	\N	\N	f	\N	t	4	f
4598	https://www.r4.com/articulos-y-analisis/valores/repsol-trading-statement-del-primer-trimestre-2024	4387	8	2025-11-05 08:45:41.370728	\N	\N	\N	f	\N	t	4	f
4599	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0173516115/5	4387	8	2025-11-05 08:45:42.568711	\N	\N	\N	f	\N	t	4	f
4600	https://www.r4.com/articulos-y-analisis/valores/aedas-homes-3t24-25-9m24-25-todo-supeditado-al-4t24-25	4412	8	2025-11-05 08:45:44.633831	\N	\N	\N	f	\N	t	4	f
4601	https://www.r4.com/articulos-y-analisis/valores/aedas-homes-previo-3t24-25-9m24-25-trimestre-de-transicion-hacia-un-fuerte-4t24-25	4412	8	2025-11-05 08:45:46.849809	\N	\N	\N	f	\N	t	4	f
4602	https://www.r4.com/articulos-y-analisis/valores/aedas-homes-1s24-25-mantiene-el-buen-tono-con-sorpresa-positiva-en-beneficio-neto	4412	8	2025-11-05 08:45:49.266711	\N	\N	\N	f	\N	t	4	f
4603	https://www.r4.com/articulos-y-analisis/valores/aedas-homes-previo-2t24-25-1s24-25-buen-tono-operativo-y-comercial	4412	8	2025-11-05 08:45:50.44203	\N	\N	\N	f	\N	t	4	f
4604	https://www.r4.com/articulos-y-analisis/valores/promotoras-aedas-homes-y-neinor-homes-podrian-pujar-por-la-promotora-de-sareb	4412	8	2025-11-05 08:45:52.650994	\N	\N	\N	f	\N	t	4	f
4605	https://www.r4.com/articulos-y-analisis/valores/aedas-homes-adquiere-el-100-de-imobiliaria-espacio	4412	8	2025-11-05 08:45:54.970047	\N	\N	\N	f	\N	t	4	f
4606	https://www.r4.com/articulos-y-analisis/valores/aedas-homes-1t24-25-acelerando-la-actividad-comercial	4412	8	2025-11-05 08:45:57.085123	\N	\N	\N	f	\N	t	4	f
4607	https://www.r4.com/articulos-y-analisis/valores/aedas-homes-visibilidad-de-negocio-con-atractivos-dividendos	4412	8	2025-11-05 08:45:59.374333	\N	\N	\N	f	\N	t	4	f
4608	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105287009	4412	8	2025-11-05 08:46:01.763247	\N	\N	\N	f	\N	t	4	f
4609	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105287009/3	4412	8	2025-11-05 08:46:03.886229	\N	\N	\N	f	\N	t	4	f
4610	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-potencial-operacion-con-aedas-homes	4421	8	2025-11-05 08:46:06.132586	\N	\N	\N	f	\N	t	4	f
4611	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-vende-5-edificios-btr-por-50-mln-eur	4421	8	2025-11-05 08:46:08.283736	\N	\N	\N	f	\N	t	4	f
4612	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-la-reciente-correccion-permite-una-nueva-entrada	4421	8	2025-11-05 08:46:10.427959	\N	\N	\N	f	\N	t	4	f
4613	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-informe-de-actividad-1t25-y-proximo-dividendo-de-0-41-eur-accion	4421	8	2025-11-05 08:46:12.783179	\N	\N	\N	f	\N	t	4	f
4614	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-4t24-2024-cumpliendo-plan-de-dividendos-con-el-negocio-de-gestion-impulsando-margenes	4421	8	2025-11-05 08:46:14.97759	\N	\N	\N	f	\N	t	4	f
4615	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-previo-4t24-2024-pendientes-de-guia-2025-y-mas-dividendos	4421	8	2025-11-05 08:46:17.215732	\N	\N	\N	f	\N	t	4	f
4616	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105251005	4421	8	2025-11-05 08:46:19.341739	\N	\N	\N	f	\N	t	4	f
4617	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105251005/3	4421	8	2025-11-05 08:46:20.518974	\N	\N	\N	f	\N	t	4	f
4618	https://www.r4.com/articulos-y-analisis/valores/grupo-amper-evolucion-en-1s-acorde-con-el-cumplimiento-de-la-guia-2025e	4433	8	2025-11-05 08:46:21.665948	\N	\N	\N	f	\N	t	4	f
4619	https://www.r4.com/articulos-y-analisis/valores/amper-rating-deuda	4433	8	2025-11-05 08:46:22.953708	\N	\N	\N	f	\N	t	4	f
4621	https://www.r4.com/articulos-y-analisis/valores/amper-anuncia-una-ampliacion-de-capital	4433	8	2025-11-05 08:46:27.539033	\N	\N	\N	f	\N	t	4	f
4622	https://www.r4.com/articulos-y-analisis/valores/amper-oportunidad-para-cambiar-el-foco-a-defensa	4433	8	2025-11-05 08:46:28.723141	\N	\N	\N	f	\N	t	4	f
4623	https://www.r4.com/articulos-y-analisis/valores/amper-entrevista-ceo-en-europa-press	4433	8	2025-11-05 08:46:31.257337	\N	\N	\N	f	\N	t	4	f
4624	https://www.r4.com/articulos-y-analisis/valores/grupo-amper-evolucion-en-2024-y-previsiones-2025e-acorde-con-el-cumplimiento-del-plan-estrategico-2023-26e	4433	8	2025-11-05 08:46:33.713107	\N	\N	\N	f	\N	t	4	f
4625	https://www.r4.com/articulos-y-analisis/valores/amper-adquisicion-navacel	4433	8	2025-11-05 08:46:35.061717	\N	\N	\N	f	\N	t	4	f
4626	https://www.r4.com/articulos-y-analisis/valores/amper-prestamo-a-intelectia-telecom	4433	8	2025-11-05 08:46:37.285077	\N	\N	\N	f	\N	t	4	f
4627	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0109260531/2	4433	8	2025-11-05 08:46:39.444525	\N	\N	\N	f	\N	t	4	f
4628	https://www.r4.com/articulos-y-analisis/valores/lda-actualizacion-valoracion-aumento-de-la-prima-media-y-el-numero-de-asegurados-mantener-p-o-1-48-eur-acc-antes-1-17-eur-acc	4444	8	2025-11-05 08:46:41.476259	\N	\N	\N	f	\N	t	4	f
4629	https://www.r4.com/articulos-y-analisis/valores/lda-1s25-se-acelera-el-crecimiento-de-asegurados-del-grupo	4444	8	2025-11-05 08:46:43.614417	\N	\N	\N	f	\N	t	4	f
4630	https://www.r4.com/articulos-y-analisis/valores/lda-1t25-se-mantiene-la-tendencia-de-recuperacion-pendientes-de-la-sostenibilidad-a-medio-plazo	4444	8	2025-11-05 08:46:45.925725	\N	\N	\N	f	\N	t	4	f
4631	https://www.r4.com/articulos-y-analisis/valores/linea-directa-control-de-la-siniestralidad-principal-reto-para-la-mejora-del-roe	4444	8	2025-11-05 08:46:47.126372	\N	\N	\N	f	\N	t	4	f
4632	https://www.r4.com/articulos-y-analisis/valores/lda-4t24-visibilidad-para-2025-de-una-continuidad-de-la-evolucion-operativa	4444	8	2025-11-05 08:46:49.447658	\N	\N	\N	f	\N	t	4	f
4633	https://www.r4.com/articulos-y-analisis/valores/lda-la-subida-de-tarifas-seguira-apoyando-la-mejora-del-roe	4444	8	2025-11-05 08:46:50.643976	\N	\N	\N	f	\N	t	4	f
4634	https://www.r4.com/articulos-y-analisis/valores/lda-2t24-se-mantienen-las-dinamicas-de-mejora-en-ratio-combinado-y-resultado-tecnico-infraponderar-p-o-0-9-eur-acc	4444	8	2025-11-05 08:46:52.930387	\N	\N	\N	f	\N	t	4	f
4635	https://www.r4.com/articulos-y-analisis/valores/lda-previo-2t24-resultado-tecnico-positivo-apoyado-por-menor-siniestralidad-bajamos-recomendacion-a-infraponderar-p-o-0-9-eur-acc	4444	8	2025-11-05 08:46:54.174348	\N	\N	\N	f	\N	t	4	f
4636	https://www.r4.com/articulos-y-analisis/valores/lda-resultados-1t24-el-crecimiento-rentable-comienza-a-aflorar-mantener-p-o-0-9-eur-acc	4444	8	2025-11-05 08:46:56.548132	\N	\N	\N	f	\N	t	4	f
4637	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105546008/2	4444	8	2025-11-05 08:46:57.741941	\N	\N	\N	f	\N	t	4	f
4638	https://www.r4.com/articulos-y-analisis/valores/previo-cellnex-9m25-consolidacion-espacio-europeo-de-telecomunicaciones-en-el-foco	4445	8	2025-11-05 08:46:59.746033	\N	\N	\N	f	\N	t	4	f
4639	https://www.r4.com/articulos-y-analisis/valores/previo-aena-9m25-es-previsible-un-cambio-en-la-guia-de-trafico-2025	4445	8	2025-11-05 08:47:00.943114	\N	\N	\N	f	\N	t	4	f
4640	https://www.r4.com/articulos-y-analisis/valores/logista-previo-2025-sin-sorpresas-esperadas-el-guidance-2026-sera-la-clave	4445	8	2025-11-05 08:47:02.129656	\N	\N	\N	f	\N	t	4	f
4641	https://www.r4.com/articulos-y-analisis/valores/grifols-potencia-la-actividad-de-diagnostico-con-la-ampliacion-de-una-planta	4445	8	2025-11-05 08:47:03.325478	\N	\N	\N	f	\N	t	4	f
4642	https://www.r4.com/articulos-y-analisis/valores/cellnex-acuerdo-de-opcion-de-venta-de-su-negocio-de-centros-de-datos-en-francia	4445	8	2025-11-05 08:47:04.536453	\N	\N	\N	f	\N	t	4	f
4643	https://www.r4.com/articulos-y-analisis/valores/8	4445	8	2025-11-05 08:47:05.773362	\N	\N	\N	f	\N	t	4	f
4644	https://www.r4.com/articulos-y-analisis/tecnico/esta-correccion-de-redeia-probablemente-es-una-oportunidad	4456	8	2025-11-05 08:47:07.034192	\N	\N	\N	f	\N	t	4	f
4645	https://www.r4.com/articulos-y-analisis/tecnico/importante-continuacion-alcista-en-alibaba	4456	8	2025-11-05 08:47:09.310023	\N	\N	\N	f	\N	t	4	f
4646	https://www.r4.com/articulos-y-analisis/tecnico/dhl-cerca-de-superar-los-maximos-de-los-ultimos-dos-anos	4456	8	2025-11-05 08:47:11.590699	\N	\N	\N	f	\N	t	4	f
4647	https://www.r4.com/articulos-y-analisis/tecnico/la-superioridad-del-ibex-35-frente-a-europa-se-intensifica	4456	8	2025-11-05 08:47:13.825243	\N	\N	\N	f	\N	t	4	f
4648	https://www.r4.com/articulos-y-analisis/tecnico/ideas-corto-plazo-18-alcista-rovi	4456	8	2025-11-05 08:47:15.040344	\N	\N	\N	f	\N	t	4	f
4649	https://www.r4.com/articulos-y-analisis/tecnico/vigilando-una-senal-de-compra-de-corto-plazo-en-laboratorios-rovi	4456	8	2025-11-05 08:47:16.26129	\N	\N	\N	f	\N	t	4	f
4650	https://www.r4.com/articulos-y-analisis/tecnico/la-proyeccion-alcista-de-amazon-es-coherente-con-estos-datos	4456	8	2025-11-05 08:47:17.447588	\N	\N	\N	f	\N	t	4	f
4651	https://www.r4.com/articulos-y-analisis/tecnico/strategy-comprar-con-parametros-asi-ha-venido-siendo-rentable	4456	8	2025-11-05 08:47:19.759266	\N	\N	\N	f	\N	t	4	f
4652	https://www.r4.com/articulos-y-analisis/tecnico/ibm-a-tiro-en-el-corto-plazo	4456	8	2025-11-05 08:47:20.996817	\N	\N	\N	f	\N	t	4	f
4653	https://www.r4.com/articulos-y-analisis/tecnico/8	4456	8	2025-11-05 08:47:22.280734	\N	\N	\N	f	\N	t	4	f
4654	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-europa-acciones-a-cierre-de-junio-de-2025	4467	8	2025-11-05 08:47:23.489758	\N	\N	\N	f	\N	t	4	f
4655	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-small-caps-global-a-cierre-de-junio-de-2025	4467	8	2025-11-05 08:47:30.850184	\N	\N	\N	f	\N	t	4	f
4656	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-bolsa-espana-a-cierre-de-junio-de-2025	4467	8	2025-11-05 08:47:33.05681	\N	\N	\N	f	\N	t	4	f
4657	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-activos-globales-a-cierre-de-junio-de-2025	4467	8	2025-11-05 08:47:35.350112	\N	\N	\N	f	\N	t	4	f
4658	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-megatendencias-tecnologia-a-cierre-de-junio-de-2025	4467	8	2025-11-05 08:47:37.671597	\N	\N	\N	f	\N	t	4	f
4659	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-cripto-a-cierre-de-junio-de-2025	4467	8	2025-11-05 08:47:39.879558	\N	\N	\N	f	\N	t	4	f
4660	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-global-dynamic-fi-a-cierre-de-mayo-de-2025	4467	8	2025-11-05 08:47:42.071671	\N	\N	\N	f	\N	t	4	f
4661	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-megatendencias-salud-a-cierre-de-mayo-de-2025	4467	8	2025-11-05 08:47:44.22537	\N	\N	\N	f	\N	t	4	f
4662	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-nexus-a-cierre-de-mayo-de-2025	4467	8	2025-11-05 08:47:46.379359	\N	\N	\N	f	\N	t	4	f
4663	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-eeuu-acciones-fi-a-cierre-de-mayo-de-2025	4467	8	2025-11-05 08:47:47.590472	\N	\N	\N	f	\N	t	4	f
4666	http://r4.com/planes-de-pensiones/como-funciona-un-plan-de-pensiones	4480	8	2025-11-05 08:47:53.164266	\N	\N	\N	f	\N	t	4	f
4667	http://r4.com/planes-de-pensiones/como-elegir-un-plan-de-pensiones	4480	8	2025-11-05 08:47:54.383398	\N	\N	\N	f	\N	t	4	f
4668	http://r4.com/planes-de-pensiones/plan-de-pensiones-autonomos	4480	8	2025-11-05 08:47:56.324302	\N	\N	\N	f	\N	t	4	f
4669	http://r4.com/planes-de-pensiones/que-es-una-epsv	4480	8	2025-11-05 08:47:58.480306	\N	\N	\N	f	\N	t	4	f
4670	http://r4.com/planes-de-pensiones/mejores-planes-de-pensiones	4480	8	2025-11-05 08:48:00.83037	\N	\N	\N	f	\N	t	4	f
4671	http://r4.com/planes-de-pensiones/fiscalidad-planes-de-pensiones	4480	8	2025-11-05 08:48:02.821497	\N	\N	\N	f	\N	t	4	f
4672	http://r4.com/planes-de-pensiones/rescate-planes-de-pensiones	4480	8	2025-11-05 08:48:04.94778	\N	\N	\N	f	\N	t	4	f
4673	http://r4.com/planes-de-pensiones/rentabilidad-planes-de-pensiones	4480	8	2025-11-05 08:48:07.019286	\N	\N	\N	f	\N	t	4	f
4674	http://r4.com/que-necesitas/red-oficinas	4480	8	2025-11-05 08:48:09.048579	\N	\N	\N	f	\N	t	4	f
4675	http://r4.com/planes-de-pensiones/tipos-planes-de-pensiones	4480	8	2025-11-05 08:48:10.234314	\N	\N	\N	f	\N	t	4	f
4676	http://r4.com/planes-de-pensiones/aportacion-maxima-planes-de-pensiones	4480	8	2025-11-05 08:48:12.151273	\N	\N	\N	f	\N	t	4	f
4678	https://www.r4.com/articulos-y-analisis/valores/sabadell-resultados-1t24-primeras-impresiones-sabadell-1t24-mejoran-guia-de-rote-para-el-ano-sobreponderar-p-o-1-94-eur-acc	4492	9	2025-11-05 08:48:15.923833	\N	\N	\N	f	\N	t	4	f
4679	https://www.r4.com/articulos-y-analisis/valores/sabadell-resultados-4t23-buena-lectura-de-las-provisiones-vs-debilidad-de-los-ingresos-recurrentes-sobreponderar-p-o-1-98-eur-acc	4492	9	2025-11-05 08:48:17.167954	\N	\N	\N	f	\N	t	4	f
4680	https://www.r4.com/articulos-y-analisis/valores/telefonica-anuncia-la-segregacion-de-la-red-de-telefonia-fija-en-reino-unido	4518	9	2025-11-05 08:48:19.449381	\N	\N	\N	f	\N	t	4	f
4681	https://www.r4.com/articulos-y-analisis/valores/telefonica-trimestre-marcado-por-la-provision-del-plan-de-bajas-en-espana-y-el-impacto-negativo-del-peso-argentino	4518	9	2025-11-05 08:48:20.680023	\N	\N	\N	f	\N	t	4	f
4682	https://www.r4.com/articulos-y-analisis/valores/telefonica-resultado-del-plan-voluntario-de-despidos-y-rumores-en-reino-unido	4518	9	2025-11-05 08:48:22.930677	\N	\N	\N	f	\N	t	4	f
4683	https://www.r4.com/articulos-y-analisis/valores/telefonica-resultado-de-la-oferta-sobre-su-filial-telefonica-alemania	4518	9	2025-11-05 08:48:25.258689	\N	\N	\N	f	\N	t	4	f
4684	https://www.r4.com/articulos-y-analisis/valores/telefonica-compra-la-mitad-de-los-derechos-audiovisuales-de-laliga-para-las-proximas-5-temporadas	4518	9	2025-11-05 08:48:26.488389	\N	\N	\N	f	\N	t	4	f
4685	https://www.r4.com/articulos-y-analisis/valores/telefonica-ha-anunciado-dos-emisiones-de-bonos-verdes	4518	9	2025-11-05 08:48:28.825989	\N	\N	\N	f	\N	t	4	f
4686	https://www.r4.com/articulos-y-analisis/ideas/rentas-vitalicias-guia-jubiliacion	4552	9	2025-11-05 08:48:31.012555	\N	\N	\N	f	\N	t	4	f
4687	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=ES0113118006&DIVI=EUR&CBR=	4563	9	2025-11-05 08:48:32.156782	\N	\N	\N	f	\N	t	4	f
4688	https://www.r4.com/articulos-y-analisis/valores/dia-2t21-se-confirma-la-exigente-comparativa-atentos-en-la-cc-a-objetivos-a-medio-plazo	4566	9	2025-11-05 08:48:33.320659	\N	\N	\N	f	\N	t	4	f
4689	https://www.r4.com/articulos-y-analisis/valores/viscofan-2t21-superan-estimaciones-en-linea-para-cumplir-holgadamente-la-guia-del-ano	4566	9	2025-11-05 08:48:35.647341	\N	\N	\N	f	\N	t	4	f
4690	https://www.r4.com/articulos-y-analisis/valores/atresmedia-2t21-superan-las-previsiones-de-consenso-pendientes-en-la-cc-a-las-previsiones-de-cara-a-2s21	4566	9	2025-11-05 08:48:36.843308	\N	\N	\N	f	\N	t	4	f
4691	https://www.r4.com/articulos-y-analisis/valores/mediaset-espana-2t21-resultados-en-linea-atentos-a-la-evolucion-del-mercado-despues-de-verano	4566	9	2025-11-05 08:48:37.995326	\N	\N	\N	f	\N	t	4	f
4692	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0141571192&MKT=MCO	4567	9	2025-11-05 08:48:40.38474	\N	\N	\N	f	\N	t	4	f
4693	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0105027009&MKT=MCO	4567	9	2025-11-05 08:48:41.546764	\N	\N	\N	f	\N	t	4	f
4694	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0109260531&MKT=MCO	4567	9	2025-11-05 08:48:42.698833	\N	\N	\N	f	\N	t	4	f
4695	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0126775008&MKT=MCO	4567	9	2025-11-05 08:48:43.850376	\N	\N	\N	f	\N	t	4	f
4696	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=CPY&COD_ISIN=ES0180907000&MKT=MCO	4567	9	2025-11-05 08:48:45.025564	\N	\N	\N	f	\N	t	4	f
4697	https://www.r4.com/articulos-y-analisis/ideas/investors-day-2025-a-rio-revuelto-ganancia-de-pescadores	4569	9	2025-11-05 08:48:46.248643	\N	\N	\N	f	\N	t	4	f
4698	https://www.r4.com/articulos-y-analisis/ideas/asml-el-cerebro-de-cada-chip-y-pieza-clave-de-la-revolucion-tecnologica	4569	9	2025-11-05 08:48:47.422284	\N	\N	\N	f	\N	t	4	f
4699	https://www.r4.com/articulos-y-analisis/ideas/correccion-de-los-mercados-oportunidad-o-peligro	4569	9	2025-11-05 08:48:48.582674	\N	\N	\N	f	\N	t	4	f
4700	https://www.r4.com/articulos-y-analisis/ideas/almirall-entra-en-nuestra-cartera-5-grandes-y-versatil	4569	9	2025-11-05 08:48:49.747041	\N	\N	\N	f	\N	t	4	f
4701	https://www.r4.com/articulos-y-analisis/ideas/cambios-de-seleccion-50-en-el-primer-trimestre-2025	4569	9	2025-11-05 08:48:52.12104	\N	\N	\N	f	\N	t	4	f
4702	https://www.r4.com/articulos-y-analisis/ideas/renta-4-renta-fija-6-meses-15-anos-de-estabilidad-y-crecimiento	4569	9	2025-11-05 08:48:54.369263	\N	\N	\N	f	\N	t	4	f
4703	https://www.r4.com/articulos-y-analisis/ideas/deepseek-y-nvidia-un-paso-mas-en-la-revolucion-del-hardware-de-ia	4569	9	2025-11-05 08:48:55.58345	\N	\N	\N	f	\N	t	4	f
4704	https://www.r4.com/articulos-y-analisis/ideas/cartera-rendimiento-nueva-gestion-discrecional-para-inversores-moderados	4569	9	2025-11-05 08:48:56.716928	\N	\N	\N	f	\N	t	4	f
4705	https://www.r4.com/articulos-y-analisis/ideas/9	4569	9	2025-11-05 08:48:59.099256	\N	\N	\N	f	\N	t	4	f
4706	https://www.r4.com/serviciosr4/estrategia	4575	9	2025-11-05 08:49:01.531656	\N	\N	\N	f	\N	t	4	f
4707	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/primeras-dudas-sobre-la-trumponomics-correccion-o-toma-de-beneficios	4577	9	2025-11-05 08:49:02.675365	\N	\N	\N	f	\N	t	4	f
4708	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-s-p-6000-da-la-bienvenida-al-realismo-transaccional-de-trump	4579	9	2025-11-05 08:49:05.045012	\N	\N	\N	f	\N	t	4	f
4709	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/es-octubre-el-anticipo-de-algo-peor	4579	9	2025-11-05 08:49:07.298351	\N	\N	\N	f	\N	t	4	f
4710	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-nasdaq-lo-intenta-en-solitario-sin-mucha-conviccion	4579	9	2025-11-05 08:49:09.622344	\N	\N	\N	f	\N	t	4	f
4711	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/bolsas-en-fase-politica-en-medio-de-los-resultados-empresariales-y-de-datos-economicos-mixtos	4579	9	2025-11-05 08:49:11.908489	\N	\N	\N	f	\N	t	4	f
4712	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/las-bolsas-se-ensanchan-y-caminan-hacia-el-s-p-6000-a-la-espera-del-evento-de-octubre	4579	9	2025-11-05 08:49:13.112895	\N	\N	\N	f	\N	t	4	f
4713	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/las-bolsas-resisten-de-momento-las-tensiones-geopoliticas-ayudadas-por-el-empleo	4579	9	2025-11-05 08:49:14.295	\N	\N	\N	f	\N	t	4	f
4714	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/china-y-su-momento-draghi-revolucionan-a-las-bolsas-sobre-todo-a-las-europeas	4579	9	2025-11-05 08:49:15.490471	\N	\N	\N	f	\N	t	4	f
4715	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/la-fed-deja-a-las-bolsas-vulnerables-y-con-poco-margen-de-error	4579	9	2025-11-05 08:49:16.680863	\N	\N	\N	f	\N	t	4	f
4716	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/unas-bolsas-fractales-cierran-la-mejor-semana-de-2024-con-ayuda-de-nvidia	4579	9	2025-11-05 08:49:17.819441	\N	\N	\N	f	\N	t	4	f
4717	https://www.r4.com/columnas-de-autores/vive-la-pasion-de-los-mercados/7	4579	9	2025-11-05 08:49:18.95034	\N	\N	\N	f	\N	t	4	f
4718	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-seguiran-subiendo-las-bolsas-europeas-si-no-lo-hacen-las-americanas	4586	9	2025-11-05 08:49:20.81451	\N	\N	\N	f	\N	t	4	f
4719	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/la-memoria-de-pez-de-los-mercados-y-las-buenas-noticias-por-venir	4587	9	2025-11-05 08:49:23.346054	\N	\N	\N	f	\N	t	4	f
4720	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/la-acertada-profecia-de-lagarde-sobre-la-guerra-comercial-de-estados-unidos-vs-china	4587	9	2025-11-05 08:49:24.494736	\N	\N	\N	f	\N	t	4	f
4721	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-vuelven-las-grandes-tecnologicas-norteamericanas-salvo-apple	4587	9	2025-11-05 08:49:26.930851	\N	\N	\N	f	\N	t	4	f
4722	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/seguridad-asequibilidad-y-sostenibilidad-medioambiental-de-la-energia	4587	9	2025-11-05 08:49:28.114777	\N	\N	\N	f	\N	t	4	f
4723	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-sap-y-microsoft-despegara-la-tecnologia-europea	4587	9	2025-11-05 08:49:30.307635	\N	\N	\N	f	\N	t	4	f
4724	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/las-empresas-chinas-cotizadas-en-estados-unidos-no-son-lo-que-parecen	4587	9	2025-11-05 08:49:31.491395	\N	\N	\N	f	\N	t	4	f
4725	https://www.r4.com/articulos-y-analisis/mercados/9	4587	9	2025-11-05 08:49:33.843768	\N	\N	\N	f	\N	t	4	f
4726	https://www.r4.com/articulos-y-analisis/id/869810?utm_source=bdd_prensa&utm_medium=e-mail&utm_campaign=enviosprensa	4588	9	2025-11-05 08:49:35.060232	\N	\N	\N	f	\N	t	4	f
4727	https://www.r4.com/articulos-y-analisis/valores/repsol-ultimando-un-acuerdo-para-hacerse-con-el-100-de-ibereolica	4599	9	2025-11-05 08:49:41.234284	\N	\N	\N	f	\N	t	4	f
4728	https://www.r4.com/articulos-y-analisis/valores/repsol-adquisicion-tres-plantas-dedicadas-a-la-produccion-de-aceites-y-biocombustibles-por-300-millones-de-dolares	4599	9	2025-11-05 08:49:42.453846	\N	\N	\N	f	\N	t	4	f
4729	https://www.r4.com/articulos-y-analisis/valores/repsol-programa-de-recompra-de-acciones	4599	9	2025-11-05 08:49:44.744942	\N	\N	\N	f	\N	t	4	f
4730	https://www.r4.com/articulos-y-analisis/valores/repsol-analizando-nuevas-oportunidades-de-crecimiento-en-renovables	4599	9	2025-11-05 08:49:46.99083	\N	\N	\N	f	\N	t	4	f
4731	https://www.r4.com/articulos-y-analisis/valores/repsol-la-administracion-de-informacion-energetica-americana-revisa-sus-estimaciones-de-oferta-y-demanda-y-precio-de-crudo-para-2024	4599	9	2025-11-05 08:49:49.411318	\N	\N	\N	f	\N	t	4	f
4732	https://www.r4.com/articulos-y-analisis/valores/repsol-venta-del-negocio-de-upstream-en-noruega	4599	9	2025-11-05 08:49:50.61526	\N	\N	\N	f	\N	t	4	f
4733	https://www.r4.com/articulos-y-analisis/valores/repsol-actualizacion-estrategica-2024-27-vientos-favorables-para-crecer-de-forma-rentable-eficiente-y-sostenible	4599	9	2025-11-05 08:49:52.968819	\N	\N	\N	f	\N	t	4	f
4734	https://www.r4.com/articulos-y-analisis/valores/repsol-4t23-mejorando-estimaciones-para-retribuir-al-accionista	4599	9	2025-11-05 08:49:55.337778	\N	\N	\N	f	\N	t	4	f
4735	https://www.r4.com/articulos-y-analisis/valores/repsol-previo-4t23-expectantes-ante-la-actualizacion-del-plan-estrategico	4599	9	2025-11-05 08:49:56.57222	\N	\N	\N	f	\N	t	4	f
4736	https://www.r4.com/articulos-y-analisis/valores/repsol-trading-statement-del-cuarto-trimestre-2023	4599	9	2025-11-05 08:49:58.807514	\N	\N	\N	f	\N	t	4	f
4737	https://www.r4.com/articulos-y-analisis/valores/aedas-homes-2023-objetivos-cumplidos-y-sorpresa-positiva-con-el-dividendo	4609	9	2025-11-05 08:50:00.947886	\N	\N	\N	f	\N	t	4	f
4738	https://www.r4.com/articulos-y-analisis/valores/aedas-homes-2023-24-pendientes-de-guia	4609	9	2025-11-05 08:50:03.174954	\N	\N	\N	f	\N	t	4	f
4739	https://www.r4.com/articulos-y-analisis/valores/aedas-homes-avanza-resultados-del-ejercicio-2023-2024-cumpliendo-objetivos	4609	9	2025-11-05 08:50:05.46525	\N	\N	\N	f	\N	t	4	f
4740	https://www.r4.com/articulos-y-analisis/valores/aedas-homes-3t23-24-9m23-24-resultados-en-linea-reiterando-objetivos-anuales	4609	9	2025-11-05 08:50:07.782357	\N	\N	\N	f	\N	t	4	f
4741	https://www.r4.com/articulos-y-analisis/valores/aedas-homes-previo-3t23-24-9m23-24-acelerando-entregas-pendientes-de-margenes	4609	9	2025-11-05 08:50:08.941268	\N	\N	\N	f	\N	t	4	f
4742	https://www.r4.com/articulos-y-analisis/valores/aedas-homes-crea-una-jv-270-mln-eur-con-king-street-para-promover-bts	4609	9	2025-11-05 08:50:11.280656	\N	\N	\N	f	\N	t	4	f
4743	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-acuerdo-con-santander-para-desarrollar-una-promocion-de-flex-living-en-madrid-por-importe-de-60-millones-de-euros	4617	9	2025-11-05 08:50:13.746593	\N	\N	\N	f	\N	t	4	f
4744	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-resultados-preliminares-2024-y-proximo-dividendo-de-0-83-eur-accion	4617	9	2025-11-05 08:50:14.919836	\N	\N	\N	f	\N	t	4	f
4745	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-anuncia-acuerdo-para-distribuir-125-millones-de-euros-de-dividendo	4617	9	2025-11-05 08:50:17.126417	\N	\N	\N	f	\N	t	4	f
4746	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-emite-bono-verde-por-importe-de-325-millones-de-euros-al-5-875	4617	9	2025-11-05 08:50:19.3517	\N	\N	\N	f	\N	t	4	f
4747	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-aprueba-una-emision-de-bonos-senior-garantizados-por-importe-de-300-millones-de-euros	4617	9	2025-11-05 08:50:21.634146	\N	\N	\N	f	\N	t	4	f
4748	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-la-operacion-de-habitat-impulsa-el-plan-de-coinversion	4617	9	2025-11-05 08:50:22.857822	\N	\N	\N	f	\N	t	4	f
4749	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-acuerdo-con-bain-capital-para-la-adquisicion-del-10-de-habitat-por-31-millones-de-euros	4617	9	2025-11-05 08:50:24.128439	\N	\N	\N	f	\N	t	4	f
4750	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-comunicado-preliminar-sobre-la-operacion-con-habitat	4617	9	2025-11-05 08:50:25.326301	\N	\N	\N	f	\N	t	4	f
4751	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-crea-una-jv-de-35-millones-de-euros-con-avenue-capital-para-el-desarrollo-de-700-unidades-en-costa-del-sol	4617	9	2025-11-05 08:50:26.583056	\N	\N	\N	f	\N	t	4	f
4752	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-estaria-en-negociaciones-para-hacerse-con-habitat	4617	9	2025-11-05 08:50:27.772897	\N	\N	\N	f	\N	t	4	f
4753	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105251005/4	4617	9	2025-11-05 08:50:28.980793	\N	\N	\N	f	\N	t	4	f
4754	https://www.r4.com/articulos-y-analisis/valores/grupo-amper-resultados-1s-24-crecimiento-alineado-con-los-objetivos-2024-p-o-y-recomendacion-en-revision	4627	9	2025-11-05 08:50:31.267641	\N	\N	\N	f	\N	t	4	f
4755	https://www.r4.com/articulos-y-analisis/valores/grupo-amper-mejor-evolucion-operativa-de-lo-previsto-en-2023-mantiene-la-guia-2024e-p-o-y-recomendacion-en-revision-antes-0-16-eur-y-sobreponderar	4627	9	2025-11-05 08:50:33.614912	\N	\N	\N	f	\N	t	4	f
4756	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0109260531	4627	9	2025-11-05 08:50:35.859388	\N	\N	\N	f	\N	t	4	f
4757	https://www.r4.com/articulos-y-analisis/valores/lda-resultados-2023-ratio-combinado-segundo-trimestre-consecutivo-a-la-baja-mantener-p-o-0-9-eur-acc	4637	9	2025-11-05 08:50:37.883728	\N	\N	\N	f	\N	t	4	f
4758	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105546008	4637	9	2025-11-05 08:50:39.055079	\N	\N	\N	f	\N	t	4	f
4759	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0105066007	4638	9	2025-11-05 08:50:41.043946	\N	\N	\N	f	\N	t	4	f
4760	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0105027009	4640	9	2025-11-05 08:50:42.251108	\N	\N	\N	f	\N	t	4	f
4761	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0171996087	4641	9	2025-11-05 08:50:44.375496	\N	\N	\N	f	\N	t	4	f
4762	https://www.r4.com/articulos-y-analisis/valores/hbx-group-actualiza-su-estructura-organizativa-y-reitera-guia-del-ano	4643	9	2025-11-05 08:50:45.567302	\N	\N	\N	f	\N	t	4	f
4763	https://www.r4.com/articulos-y-analisis/valores/acs-previo-acs-9m25-consideramos-que-el-foco-estara-en-la-visibilidad-a-medio-plazo	4643	9	2025-11-05 08:50:47.720292	\N	\N	\N	f	\N	t	4	f
4764	https://www.r4.com/articulos-y-analisis/valores/amadeus-previo-3t-25-deberia-confirmarse-un-crecimiento-mas-moderado-en-linea-con-el-de-2t-p-o-71-2-eur-mantener	4643	9	2025-11-05 08:50:48.941683	\N	\N	\N	f	\N	t	4	f
4765	https://www.r4.com/articulos-y-analisis/valores/dia-poniendose-al-dia-con-mayor-crecimiento-y-rentabilidad	4643	9	2025-11-05 08:50:50.144204	\N	\N	\N	f	\N	t	4	f
4766	https://www.r4.com/articulos-y-analisis/valores/9	4643	9	2025-11-05 08:50:52.359853	\N	\N	\N	f	\N	t	4	f
4767	https://www.r4.com/articulos-y-analisis/tecnico/europa-y-usa-niveles-a-tener-en-cuenta-en-agosto	4653	9	2025-11-05 08:50:53.595424	\N	\N	\N	f	\N	t	4	f
4768	https://www.r4.com/articulos-y-analisis/tecnico/ideas-corto-plazo-17-sanofi-stop-loss-77-50-euros-8-36	4653	9	2025-11-05 08:50:55.83644	\N	\N	\N	f	\N	t	4	f
4769	https://www.r4.com/articulos-y-analisis/tecnico/s-p500-pauta-envolvente-que-favorece-una-toma-de-beneficios-en-6-430-puntos	4653	9	2025-11-05 08:50:58.056947	\N	\N	\N	f	\N	t	4	f
4770	https://www.r4.com/articulos-y-analisis/tecnico/nestle-de-nuevo-en-zonas-atractivas-de-corto-plazo	4653	9	2025-11-05 08:51:00.268218	\N	\N	\N	f	\N	t	4	f
4771	https://www.r4.com/articulos-y-analisis/tecnico/2020-y-2025-dow-jones-industriales-y-s-p500	4653	9	2025-11-05 08:51:01.436411	\N	\N	\N	f	\N	t	4	f
4772	https://www.r4.com/articulos-y-analisis/tecnico/el-punto-clave-del-s-p500-que-nos-podria-dar-una-pista-de-correccion-en-agosto	4653	9	2025-11-05 08:51:03.618333	\N	\N	\N	f	\N	t	4	f
4773	https://www.r4.com/articulos-y-analisis/tecnico/coinbase-alcanza-los-objetivos-minimos-alcistas-apuntados-en-2023	4653	9	2025-11-05 08:51:04.805311	\N	\N	\N	f	\N	t	4	f
4774	https://www.r4.com/articulos-y-analisis/tecnico/ranking-espanolas-con-mayores-dividendos-y-sus-niveles-clave	4653	9	2025-11-05 08:51:06.024377	\N	\N	\N	f	\N	t	4	f
4775	https://www.r4.com/articulos-y-analisis/tecnico/recuperara-apple-el-mejor-comportamiento-relativo-vs-s-p500-y-nasdaq	4653	9	2025-11-05 08:51:07.227053	\N	\N	\N	f	\N	t	4	f
4776	https://www.r4.com/articulos-y-analisis/tecnico/moncler-buena-ecuacion-rentabilidad-riesgo-en-el-soporte-de-los-dos-ultimos-anos	4653	9	2025-11-05 08:51:09.583477	\N	\N	\N	f	\N	t	4	f
4777	https://www.r4.com/articulos-y-analisis/tecnico/9	4653	9	2025-11-05 08:51:10.863817	\N	\N	\N	f	\N	t	4	f
4778	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-pegasus-a-cierre-de-mayo-de-2025	4664	9	2025-11-05 08:51:13.04446	\N	\N	\N	f	\N	t	4	f
4779	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-cripto-a-cierre-de-mayo-de-2025	4664	9	2025-11-05 08:51:15.490188	\N	\N	\N	f	\N	t	4	f
4780	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-europa-acciones-a-cierre-de-mayo-de-2025	4664	9	2025-11-05 08:51:16.740117	\N	\N	\N	f	\N	t	4	f
4781	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-latinoamerica-a-cierre-de-mayo-de-2025	4664	9	2025-11-05 08:51:19.111411	\N	\N	\N	f	\N	t	4	f
4782	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-activos-globales-a-cierre-de-mayo-de-2025	4664	9	2025-11-05 08:51:20.374155	\N	\N	\N	f	\N	t	4	f
4783	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-renta-fija-mixto-a-cierre-de-mayo-de-2025	4664	9	2025-11-05 08:51:22.567307	\N	\N	\N	f	\N	t	4	f
4784	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-bolsa-espana-a-cierre-de-mayo-de-2025	4664	9	2025-11-05 08:51:23.779641	\N	\N	\N	f	\N	t	4	f
4785	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-megatendencias-medio-ambiente-a-cierre-de-mayo-de-2025	4664	9	2025-11-05 08:51:26.035788	\N	\N	\N	f	\N	t	4	f
4786	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-megatendencias-consumo-a-cierre-de-mayo-de-2025	4664	9	2025-11-05 08:51:27.249146	\N	\N	\N	f	\N	t	4	f
4787	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-alpha-global-a-cierre-de-mayo-de-2025	4664	9	2025-11-05 08:51:28.440051	\N	\N	\N	f	\N	t	4	f
4788	https://www.r4.com/articulos-y-analisis/fondos/9	4664	9	2025-11-05 08:51:29.63244	\N	\N	\N	f	\N	t	4	f
4789	https://www.r4.com/articulos-y-analisis/ideas/en-que-consiste-la-exencion-fiscal-por-reinversion-en-rentas-vitalicias	4686	10	2025-11-05 08:51:31.641693	\N	\N	\N	f	\N	t	4	f
4790	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0126775032	4688	10	2025-11-05 08:51:32.864939	\N	\N	\N	f	\N	t	4	f
4791	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0184262212	4689	10	2025-11-05 08:51:34.985686	\N	\N	\N	f	\N	t	4	f
4792	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU0132601682&DIVI=EUR&CBR=	4701	10	2025-11-05 08:51:36.963884	\N	\N	\N	f	\N	t	4	f
4793	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=FR0011253624&DIVI=EUR&CBR=	4701	10	2025-11-05 08:51:38.139934	\N	\N	\N	f	\N	t	4	f
4794	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=LU1366712435&DIVI=EUR&CBR=	4701	10	2025-11-05 08:51:39.286504	\N	\N	\N	f	\N	t	4	f
4795	https://www.r4.com/portal?FWD=CNT002&TX=goto&TP=1&DST=FND&COD_ISIN=ES0128520006&DIVI=EUR&CBR=	4702	10	2025-11-05 08:51:40.484811	\N	\N	\N	f	\N	t	4	f
4796	https://www.r4.com/articulos-y-analisis/ideas/deepseek-y-su-impacto-en-el-mercado-de-hardware-de-ia	4703	10	2025-11-05 08:51:41.647475	\N	\N	\N	f	\N	t	4	f
4797	https://www.r4.com/articulos-y-analisis/ideas/cuando-lo-caro-sale-barato-por-que-somos-accionistas-de-hermes-a-50x-per	4705	10	2025-11-05 08:51:42.9447	\N	\N	\N	f	\N	t	4	f
4798	https://www.r4.com/articulos-y-analisis/ideas/alphabet-lider-tecnologico-a-largo-plazo	4705	10	2025-11-05 08:51:44.147484	\N	\N	\N	f	\N	t	4	f
4799	https://www.r4.com/articulos-y-analisis/ideas/brasil-un-mercado-con-oportunidades-de-inversion-interesantes	4705	10	2025-11-05 08:51:46.407244	\N	\N	\N	f	\N	t	4	f
4800	https://www.r4.com/articulos-y-analisis/ideas/la-nueva-fiebre-del-oro	4705	10	2025-11-05 08:51:48.780716	\N	\N	\N	f	\N	t	4	f
4801	https://www.r4.com/articulos-y-analisis/ideas/auge-en-el-gasto-de-defensa-europeo-nuevo-horizonte	4705	10	2025-11-05 08:51:51.139516	\N	\N	\N	f	\N	t	4	f
4802	https://www.r4.com/articulos-y-analisis/ideas/vision-de-mercado-febrero-2025-los-aranceles-de-trump-elevaran-la-volatilidad-de-los-mercados	4705	10	2025-11-05 08:51:52.338589	\N	\N	\N	f	\N	t	4	f
4803	https://www.r4.com/articulos-y-analisis/ideas/como-empezar-a-invertir-con-poco-dinero	4705	10	2025-11-05 08:51:54.553413	\N	\N	\N	f	\N	t	4	f
4804	https://www.r4.com/articulos-y-analisis/ideas/empresas-espanolas-beneficiadas-por-los-aranceles-de-trump	4705	10	2025-11-05 08:51:56.925895	\N	\N	\N	f	\N	t	4	f
4805	https://www.r4.com/articulos-y-analisis/ideas/10	4705	10	2025-11-05 08:51:59.299584	\N	\N	\N	f	\N	t	4	f
4806	https://www.r4.com/centro-de-ayuda	4708	10	2025-11-05 08:52:00.56674	\N	\N	\N	f	\N	t	4	f
4807	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/las-dudas-sobre-el-crecimiento-complican-la-situacion-tecnica-del-nasdaq-y-del-s-p	4716	10	2025-11-05 08:52:01.821026	\N	\N	\N	f	\N	t	4	f
4808	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/nvidia-y-las-expectativas-de-crecimiento-seguiran-marcando-el-guion-de-las-bolsas	4716	10	2025-11-05 08:52:04.050556	\N	\N	\N	f	\N	t	4	f
4809	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/un-powell-casi-biblico-acerca-mas-al-s-p-a-los-maximos-historicos	4717	10	2025-11-05 08:52:05.287439	\N	\N	\N	f	\N	t	4	f
4810	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/resultados-y-datos-macro-reviven-el-s-p-6-000-a-la-espera-de-jackson-hole	4717	10	2025-11-05 08:52:06.501055	\N	\N	\N	f	\N	t	4	f
4811	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/que-hay-detras-del-yen-trade-una-vision-alternativa-de-la-caida-de-las-bolsas	4717	10	2025-11-05 08:52:07.686511	\N	\N	\N	f	\N	t	4	f
4812	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/las-bolsas-y-el-vuelo-de-icaro	4717	10	2025-11-05 08:52:08.977239	\N	\N	\N	f	\N	t	4	f
4813	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/los-resultados-impulsan-tambien-la-rotacion-que-sigue-siendo-ordenada	4717	10	2025-11-05 08:52:11.203342	\N	\N	\N	f	\N	t	4	f
4814	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-trump-trade-impulsa-la-rotacion-pero-explica-lo-que-esta-pasando-en-las-bolsas	4717	10	2025-11-05 08:52:12.410542	\N	\N	\N	f	\N	t	4	f
4815	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/liquidez-y-subidas-se-retroalimentan-y-provocan-reacciones-sorprendentes	4717	10	2025-11-05 08:52:13.63631	\N	\N	\N	f	\N	t	4	f
4816	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/las-bolsas-superan-el-factor-politico-con-nuevos-maximos-a-la-espera-de-los-resultados-empresariales	4717	10	2025-11-05 08:52:14.87839	\N	\N	\N	f	\N	t	4	f
4817	https://www.r4.com/columnas-de-autores/vive-la-pasion-de-los-mercados/8	4717	10	2025-11-05 08:52:16.118934	\N	\N	\N	f	\N	t	4	f
4818	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-las-bolsas-europeas-celebran-tambien-la-edad-de-oro-de-trump	4718	10	2025-11-05 08:52:18.035228	\N	\N	\N	f	\N	t	4	f
4819	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-vuelve-europa	4718	10	2025-11-05 08:52:19.241202	\N	\N	\N	f	\N	t	4	f
4820	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-nvidia-y-netflix-nos-recuerdan-que-los-resultados-seguiran-mandando-en-las-bolsas-de-trump	4723	10	2025-11-05 08:52:21.554362	\N	\N	\N	f	\N	t	4	f
4821	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/europa-es-la-gran-damnificada-de-la-guerra-comercial-ee-uu-vs-china	4725	10	2025-11-05 08:52:22.826958	\N	\N	\N	f	\N	t	4	f
4822	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-el-dolar-refleja-las-dudas-sobre-estados-unidos	4725	10	2025-11-05 08:52:25.095656	\N	\N	\N	f	\N	t	4	f
4823	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/a-quien-perjudican-los-aranceles	4725	10	2025-11-05 08:52:27.345482	\N	\N	\N	f	\N	t	4	f
4824	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/el-grafico-semanal-el-petroleo-ayudara-a-compensar-el-impacto-de-los-aranceles	4725	10	2025-11-05 08:52:28.592436	\N	\N	\N	f	\N	t	4	f
4825	https://www.r4.com/articulos-y-analisis/opinion-de-expertos/alguien-cree-que-estos-seran-los-aranceles-definitivos	4725	10	2025-11-05 08:52:29.848634	\N	\N	\N	f	\N	t	4	f
4826	https://www.r4.com/articulos-y-analisis/mercados/10	4725	10	2025-11-05 08:52:32.084272	\N	\N	\N	f	\N	t	4	f
4827	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-resultados-1s24-solida-operativa-para-dar-visibilidad-al-dividendo-rebajamos-recomendacion-a-mantener-desde-sobreponderar	4753	10	2025-11-05 08:52:33.347917	\N	\N	\N	f	\N	t	4	f
4828	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-refinanciacion-de-prestamo-verde-sindicado	4753	10	2025-11-05 08:52:35.488773	\N	\N	\N	f	\N	t	4	f
4829	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-visibilidad-sobre-el-plan-de-dividendos	4753	10	2025-11-05 08:52:37.789164	\N	\N	\N	f	\N	t	4	f
4830	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-2023-objetivos-cumplidos-y-visibilidad-ampliada	4753	10	2025-11-05 08:52:40.095502	\N	\N	\N	f	\N	t	4	f
4831	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-previo-4t23-2023-pendientes-de-guia-y-reiteracion-de-objetivo-de-dividendos	4753	10	2025-11-05 08:52:42.386282	\N	\N	\N	f	\N	t	4	f
4832	https://www.r4.com/articulos-y-analisis/valores/neinor-homes-resultados-preliminares-2023	4753	10	2025-11-05 08:52:43.582009	\N	\N	\N	f	\N	t	4	f
4833	https://www.r4.com/articulos-y-analisis/valores/cellnex-1s25-flujo-de-caja-mejora-sensiblemente-nuestras-perspectivas	4759	10	2025-11-05 08:52:45.88964	\N	\N	\N	f	\N	t	4	f
4834	https://www.r4.com/articulos-y-analisis/valores/previo-cellnex-1s25-esperamos-que-el-crecimiento-organico-se-mantenga-solido	4759	10	2025-11-05 08:52:48.136939	\N	\N	\N	f	\N	t	4	f
4835	https://www.r4.com/articulos-y-analisis/valores/cellnex-1t25-mas-capex-bts-del-previsto-mejorara-fcf-a-futuro	4759	10	2025-11-05 08:52:50.277999	\N	\N	\N	f	\N	t	4	f
4836	https://www.r4.com/articulos-y-analisis/valores/previo-cellnex-1t25-cifras-reflejan-las-desinversiones	4759	10	2025-11-05 08:52:51.514841	\N	\N	\N	f	\N	t	4	f
4837	https://www.r4.com/articulos-y-analisis/valores/cellnex-crecimiento-organico-y-catalizadores-apoyaran-a-la-cotizacion	4759	10	2025-11-05 08:52:53.84931	\N	\N	\N	f	\N	t	4	f
4838	https://www.r4.com/articulos-y-analisis/valores/conclusiones-cellnex-2024-gran-capacidad-para-controlar-los-riesgos	4759	10	2025-11-05 08:52:55.971319	\N	\N	\N	f	\N	t	4	f
4839	https://www.r4.com/articulos-y-analisis/valores/cellnex-2024-la-generacion-de-caja-mejor-de-lo-previsto-adaptan-guias-tras-desinversiones	4759	10	2025-11-05 08:52:57.207319	\N	\N	\N	f	\N	t	4	f
4840	https://www.r4.com/articulos-y-analisis/valores/previo-cellnex-2024-pendientes-del-comienzo-de-la-recompra-de-acciones	4759	10	2025-11-05 08:52:59.393369	\N	\N	\N	f	\N	t	4	f
4841	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105066007/2	4759	10	2025-11-05 08:53:01.678476	\N	\N	\N	f	\N	t	4	f
4842	https://www.r4.com/articulos-y-analisis/valores/logista-9m25-sin-sorpresas	4760	10	2025-11-05 08:53:03.656249	\N	\N	\N	f	\N	t	4	f
4843	https://www.r4.com/articulos-y-analisis/valores/logista-previo-9m25-trimestre-de-transicion	4760	10	2025-11-05 08:53:04.882344	\N	\N	\N	f	\N	t	4	f
4844	https://www.r4.com/articulos-y-analisis/valores/logista-1s25-nuevo-ajuste-a-la-baja-del-guidance-2025	4760	10	2025-11-05 08:53:06.092456	\N	\N	\N	f	\N	t	4	f
4845	https://www.r4.com/articulos-y-analisis/valores/logista-previo-1s25-no-descartamos-un-nuevo-ajuste-a-la-baja-del-guidance	4760	10	2025-11-05 08:53:07.311122	\N	\N	\N	f	\N	t	4	f
4846	https://www.r4.com/articulos-y-analisis/valores/logista-1t25-rebaja-guidance-2025	4760	10	2025-11-05 08:53:08.518414	\N	\N	\N	f	\N	t	4	f
4847	https://www.r4.com/articulos-y-analisis/valores/logista-previo-1t25-comenzando-el-ano-por-debajo-del-guidance	4760	10	2025-11-05 08:53:10.645163	\N	\N	\N	f	\N	t	4	f
4848	https://www.r4.com/articulos-y-analisis/valores/logista-2024-guidance-ligeramente-mejor-de-lo-esperado	4760	10	2025-11-05 08:53:11.924411	\N	\N	\N	f	\N	t	4	f
4849	https://www.r4.com/articulos-y-analisis/valores/logista-9m24-sin-sorpresas	4760	10	2025-11-05 08:53:14.215913	\N	\N	\N	f	\N	t	4	f
4850	https://www.r4.com/articulos-y-analisis/valores/logista-previo-9m24-buenos-resultados-esperados	4760	10	2025-11-05 08:53:16.490185	\N	\N	\N	f	\N	t	4	f
4851	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0105027009/2	4760	10	2025-11-05 08:53:18.645751	\N	\N	\N	f	\N	t	4	f
4852	https://www.r4.com/articulos-y-analisis/valores/grifols-2t25-acelera-la-generacion-de-caja-y-desapalancamiento-financiero	4761	10	2025-11-05 08:53:20.628674	\N	\N	\N	f	\N	t	4	f
4853	https://www.r4.com/articulos-y-analisis/valores/grifols-grifols-biotest-holdings-lanza-una-opa-sobre-el-capital-de-biotest	4761	10	2025-11-05 08:53:22.84669	\N	\N	\N	f	\N	t	4	f
4854	https://www.r4.com/articulos-y-analisis/valores/grifols-4t24-crecimiento-expansion-de-margenes-generacion-de-flujo-de-caja-y-desapalancamiento	4761	10	2025-11-05 08:53:24.102044	\N	\N	\N	f	\N	t	4	f
4855	https://www.r4.com/articulos-y-analisis/valores/grifols-pre-4t24-la-fortaleza-en-la-demanda-de-inmunoglobulinas-permitira-alcanzar-las-guias	4761	10	2025-11-05 08:53:26.359946	\N	\N	\N	f	\N	t	4	f
4856	https://www.r4.com/articulos-y-analisis/valores/grifols-accionistas-de-la-compania-continuan-exigiendo-una-mayor-transparencia	4761	10	2025-11-05 08:53:28.923851	\N	\N	\N	f	\N	t	4	f
4857	https://www.r4.com/articulos-y-analisis/valores/grifols-2t24-se-acelera-la-mejora-operativa	4761	10	2025-11-05 08:53:30.150027	\N	\N	\N	f	\N	t	4	f
4858	https://www.r4.com/articulos-y-analisis/valores/grifols-pre-2t24-continua-el-crecimiento-del-negocio-combinado-con-la-expansion-de-los-margenes-y-el-desapalancamiento-financiero	4761	10	2025-11-05 08:53:31.380731	\N	\N	\N	f	\N	t	4	f
4859	https://www.r4.com/articulos-y-analisis/valores/grifols-posible-interes-de-la-familia-grifols-y-brookfield-en-lanzar-una-opa	4761	10	2025-11-05 08:53:33.701645	\N	\N	\N	f	\N	t	4	f
4860	https://www.r4.com/articulos-y-analisis/valores/grifols-anuncia-que-ha-completado-la-venta-de-una-participacion-del-20-en-sraas	4761	10	2025-11-05 08:53:34.96328	\N	\N	\N	f	\N	t	4	f
4861	https://www.r4.com/articulos-y-analisis/valores/MCO+ES0171996087/2	4761	10	2025-11-05 08:53:36.223707	\N	\N	\N	f	\N	t	4	f
4862	https://www.r4.com/articulos-y-analisis/valores.MCO%2BGB00BNXJB679	4762	10	2025-11-05 08:53:38.423793	\N	\N	\N	f	\N	t	4	f
4863	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0167050915	4763	10	2025-11-05 08:53:40.495389	\N	\N	\N	f	\N	t	4	f
4864	https://www.r4.com/articulos-y-analisis/valores.MCO%2BES0109067019	4764	10	2025-11-05 08:53:41.733211	\N	\N	\N	f	\N	t	4	f
4865	https://www.r4.com/articulos-y-analisis/valores/iberdrola-refuerza-giro-hacia-negocios-regulados-y-contratos-a-largo-plazo	4766	10	2025-11-05 08:53:43.852498	\N	\N	\N	f	\N	t	4	f
4866	https://www.r4.com/articulos-y-analisis/valores/10	4766	10	2025-11-05 08:53:45.078397	\N	\N	\N	f	\N	t	4	f
4867	https://www.r4.com/articulos-y-analisis/tecnico/kering-zona-idonea-para-un-importante-suelo-de-largo-plazo	4777	10	2025-11-05 08:53:47.124145	\N	\N	\N	f	\N	t	4	f
4868	https://www.r4.com/articulos-y-analisis/tecnico/las-empresas-del-s-p500-mas-volatiles-rompen-al-alza-maximos-de-4-anos	4777	10	2025-11-05 08:53:48.323243	\N	\N	\N	f	\N	t	4	f
4869	https://www.r4.com/articulos-y-analisis/tecnico/asml-configura-entre-710-y-750-euros-un-nivel-clave-de-resistencia-intermedia	4777	10	2025-11-05 08:53:50.596329	\N	\N	\N	f	\N	t	4	f
4870	https://www.r4.com/articulos-y-analisis/tecnico/la-clave-alcista-de-michelin-se-situa-en-34-4-euros	4777	10	2025-11-05 08:53:53.00351	\N	\N	\N	f	\N	t	4	f
4871	https://www.r4.com/articulos-y-analisis/tecnico/los-puntos-clave-de-nvidia	4777	10	2025-11-05 08:53:55.206441	\N	\N	\N	f	\N	t	4	f
4872	https://www.r4.com/articulos-y-analisis/tecnico/lemonade-seguros-por-inteligencia-artificial	4777	10	2025-11-05 08:53:57.315435	\N	\N	\N	f	\N	t	4	f
4873	https://www.r4.com/articulos-y-analisis/tecnico/si-teoricamente-al-russell2000-le-queda-al-menos-un-15-de-subida-cuanto-al-s-p500	4777	10	2025-11-05 08:53:59.744354	\N	\N	\N	f	\N	t	4	f
4874	https://www.r4.com/articulos-y-analisis/tecnico/el-eurostoxx-50-se-mantiene-debajo-de-los-maximos-de-febrero-resultados-en-usa	4777	10	2025-11-05 08:54:00.943367	\N	\N	\N	f	\N	t	4	f
4875	https://www.r4.com/articulos-y-analisis/tecnico/2o-parte-tesla-atentos-a-la-cercania-de-una-senal-de-compra-de-corto-plazo-0-3-meses	4777	10	2025-11-05 08:54:02.451574	\N	\N	\N	f	\N	t	4	f
4876	https://www.r4.com/articulos-y-analisis/tecnico/10	4777	10	2025-11-05 08:54:04.727541	\N	\N	\N	f	\N	t	4	f
4877	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-megatendencias-tecnologia-a-cierre-de-mayo-de-2025	4788	10	2025-11-05 08:54:06.910023	\N	\N	\N	f	\N	t	4	f
4878	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-small-caps-global-a-cierre-de-mayo-de-2025	4788	10	2025-11-05 08:54:09.026149	\N	\N	\N	f	\N	t	4	f
4879	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-megatendencias-salud-a-cierre-de-abril-de-2025	4788	10	2025-11-05 08:54:11.494943	\N	\N	\N	f	\N	t	4	f
4880	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-alpha-global-a-cierre-de-abril-de-2025	4788	10	2025-11-05 08:54:13.630898	\N	\N	\N	f	\N	t	4	f
4881	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-cripto-a-cierre-de-abril-de-2025	4788	10	2025-11-05 08:54:15.773906	\N	\N	\N	f	\N	t	4	f
4882	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-pegasus-a-cierre-de-abril-de-2025	4788	10	2025-11-05 08:54:17.936662	\N	\N	\N	f	\N	t	4	f
4883	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-megatendencias-medio-ambiente-a-cierre-de-abril-de-2025	4788	10	2025-11-05 08:54:19.164402	\N	\N	\N	f	\N	t	4	f
4884	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-nexus-a-cierre-de-abril-de-2025	4788	10	2025-11-05 08:54:21.534389	\N	\N	\N	f	\N	t	4	f
4885	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-eeuu-acciones-fi-a-cierre-de-abril-de-2025	4788	10	2025-11-05 08:54:22.856403	\N	\N	\N	f	\N	t	4	f
4886	https://www.r4.com/articulos-y-analisis/fondos/informe-de-seguimiento-renta-4-bolsa-espana-a-cierre-de-abril-de-2025	4788	10	2025-11-05 08:54:24.996773	\N	\N	\N	f	\N	t	4	f
4887	https://www.r4.com/articulos-y-analisis/fondos/10	4788	10	2025-11-05 08:54:27.271625	\N	\N	\N	f	\N	t	4	f
2	https://www.r4.com	\N	0	2025-11-04 21:20:34.360582	2025-11-05 07:41:33.730767	\N	\N	f	\N	t	4	t
9	https://www.r4.com/carteras-gestionadas/carteras-de-fondos	2	1	2025-11-04 21:20:42.860271	2025-11-05 07:41:42.045451	\N	\N	f	\N	t	4	t
8	https://www.r4.com/carteras-gestionadas	2	1	2025-11-04 21:20:41.603099	2025-11-05 07:41:40.890208	\N	\N	f	\N	t	4	t
10	https://www.r4.com/carteras-gestionadas/carteras-de-fondos/conservadora	2	1	2025-11-04 21:20:44.059435	2025-11-05 07:41:43.227893	\N	\N	f	\N	t	4	t
11	https://www.r4.com/carteras-gestionadas/carteras-de-fondos/moderada	2	1	2025-11-04 21:20:45.28084	2025-11-05 07:41:44.48884	\N	\N	f	\N	t	4	t
12	https://www.r4.com/carteras-gestionadas/carteras-de-fondos/dinamica	2	1	2025-11-04 21:20:46.499928	2025-11-05 07:41:45.742621	\N	\N	f	\N	t	4	t
13	https://www.r4.com/carteras-gestionadas/carteras-de-fondos/tolerante	2	1	2025-11-04 21:20:48.896702	2025-11-05 07:41:46.896678	\N	\N	f	\N	t	4	t
14	https://www.r4.com/carteras-gestionadas/carteras-de-fondos/rendimiento	2	1	2025-11-04 21:20:50.158145	2025-11-05 07:41:48.042371	\N	\N	f	\N	t	4	t
15	https://www.r4.com/carteras-gestionadas/carteras-acciones	2	1	2025-11-04 21:20:51.376212	2025-11-05 07:41:49.211295	\N	\N	f	\N	t	4	t
16	https://www.r4.com/carteras-gestionadas/carteras-acciones/cardiv	2	1	2025-11-04 21:20:52.557249	2025-11-05 07:41:50.425511	\N	\N	f	\N	t	4	t
17	https://www.r4.com/carteras-gestionadas/carteras-acciones/5-grandes	2	1	2025-11-04 21:20:53.806997	2025-11-05 07:41:51.598707	\N	\N	f	\N	t	4	t
18	https://www.r4.com/carteras-gestionadas/carteras-acciones/versatil	2	1	2025-11-04 21:20:55.103231	2025-11-05 07:41:52.839307	\N	\N	f	\N	t	4	t
19	https://www.r4.com/carteras-gestionadas/gestion-personalizada	2	1	2025-11-04 21:20:56.356564	2025-11-05 07:41:54.027184	\N	\N	f	\N	t	4	t
20	https://www.r4.com/fondos-planes	2	1	2025-11-04 21:20:57.549325	2025-11-05 07:41:55.163975	\N	\N	f	\N	t	4	t
22	https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-renta-variable	2	1	2025-11-04 21:21:00.182369	2025-11-05 07:41:57.599449	\N	\N	f	\N	t	4	t
23	https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-tematicos	2	1	2025-11-04 21:21:01.78768	2025-11-05 07:41:58.832843	\N	\N	f	\N	t	4	t
24	https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-renta-fija	2	1	2025-11-04 21:21:04.393198	2025-11-05 07:42:00.095743	\N	\N	f	\N	t	4	t
25	https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-monetarios	2	1	2025-11-04 21:21:05.648378	2025-11-05 07:42:01.314944	\N	\N	f	\N	t	4	t
26	https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-retorno-absoluto	2	1	2025-11-04 21:21:07.087606	2025-11-05 07:42:02.506961	\N	\N	f	\N	t	4	t
27	https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-mixtos	2	1	2025-11-04 21:21:08.283847	2025-11-05 07:42:03.931336	\N	\N	f	\N	t	4	t
28	https://www.r4.com/fondos-de-inversion/categorias/fondos-perfilados	2	1	2025-11-04 21:21:10.942735	2025-11-05 07:42:05.165224	\N	\N	f	\N	t	4	t
29	https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-criptomonedas	2	1	2025-11-04 21:21:12.227405	2025-11-05 07:42:06.361423	\N	\N	f	\N	t	4	t
30	https://www.r4.com/fondos-de-inversion/seleccion50	2	1	2025-11-04 21:21:13.419548	2025-11-05 07:42:07.562585	\N	\N	f	\N	t	4	t
31	https://www.r4.com/planes-de-pensiones	2	1	2025-11-04 21:21:15.679723	2025-11-05 07:42:09.584419	\N	\N	f	\N	t	4	t
33	https://www.r4.com/broker-online	2	1	2025-11-04 21:21:19.428761	2025-11-05 07:42:12.158758	\N	\N	f	\N	t	4	t
34	https://www.r4.com/broker-online/productos-de-inversion/bolsa	2	1	2025-11-04 21:21:20.59592	2025-11-05 07:42:13.340847	\N	\N	f	\N	t	4	t
35	https://www.r4.com/broker-online/productos-de-inversion/etfs	2	1	2025-11-04 21:21:21.767721	2025-11-05 07:42:14.572178	\N	\N	f	\N	t	4	t
36	https://www.r4.com/broker-online/productos-de-inversion/cfds	2	1	2025-11-04 21:21:23.099165	2025-11-05 07:42:15.73114	\N	\N	f	\N	t	4	t
37	https://www.r4.com/broker-online/productos-de-inversion/derivados	2	1	2025-11-04 21:21:24.2815	2025-11-05 07:42:16.908371	\N	\N	f	\N	t	4	t
38	https://www.r4.com/broker-online/productos-de-inversion/warrants	2	1	2025-11-04 21:21:25.442455	2025-11-05 07:42:18.048463	\N	\N	f	\N	t	4	t
39	https://www.r4.com/broker-online/productos-de-inversion/cripto	2	1	2025-11-04 21:21:26.608704	2025-11-05 07:42:19.286896	\N	\N	f	\N	t	4	t
69	https://www.r4.com/renta-fija/letras-del-tesoro	2	1	2025-11-04 21:22:01.25406	2025-11-05 07:42:53.90545	\N	\N	f	\N	t	4	t
70	https://www.r4.com/renta-fija/invertir-bonos-renta-fija	2	1	2025-11-04 21:22:02.474259	2025-11-05 07:42:55.054135	\N	\N	f	\N	t	4	t
71	https://www.r4.com/renta-fija/letras-del-tesoro/que-son-las-letras-del-tesoro	2	1	2025-11-04 21:22:03.67832	2025-11-05 07:42:56.204603	\N	\N	f	\N	t	4	t
79	https://www.r4.com/soluciones-easy	2	1	2025-11-04 21:22:12.852355	2025-11-05 07:43:05.358774	\N	\N	f	\N	t	4	t
81	https://www.r4.com/soluciones-easy/plan-easy	2	1	2025-11-04 21:22:15.362805	2025-11-05 07:43:07.704683	\N	\N	f	\N	t	4	t
82	https://www.r4.com/soluciones-easy/fondos-perfilados	2	1	2025-11-04 21:22:16.630441	2025-11-05 07:43:08.952524	\N	\N	f	\N	t	4	t
83	https://www.r4.com/soluciones-easy/asesoramiento-easy	2	1	2025-11-04 21:22:17.849068	2025-11-05 07:43:10.101148	\N	\N	f	\N	t	4	t
84	https://www.r4.com/articulos-y-analisis	2	1	2025-11-04 21:22:19.052383	2025-11-05 07:43:11.251694	\N	\N	f	\N	t	4	t
85	https://www.r4.com/articulos-y-analisis/ideas	2	1	2025-11-04 21:22:20.22336	2025-11-05 07:43:13.419761	\N	\N	f	\N	t	4	t
86	https://www.r4.com/articulos-y-analisis/mercados	2	1	2025-11-04 21:22:21.387008	2025-11-05 07:43:14.548198	\N	\N	f	\N	t	4	t
88	https://www.r4.com/articulos-y-analisis/tecnico	2	1	2025-11-04 21:22:23.761569	2025-11-05 07:43:16.867434	\N	\N	f	\N	t	4	t
89	https://www.r4.com/articulos-y-analisis/fondos	2	1	2025-11-04 21:22:24.959069	2025-11-05 07:43:18.016341	\N	\N	f	\N	t	4	t
90	https://www.r4.com/articulos-y-analisis/cripto	2	1	2025-11-04 21:22:26.17067	2025-11-05 07:43:19.173185	\N	\N	f	\N	t	4	t
93	https://www.r4.com/tarifas	2	1	2025-11-04 21:22:29.65965	2025-11-05 07:43:22.638701	\N	\N	f	\N	t	4	t
100	https://www.r4.com/asesoramiento	2	1	2025-11-04 21:22:38.485022	2025-11-05 07:43:31.352192	\N	\N	f	\N	t	4	t
101	https://www.r4.com/que-necesitas/red-oficinas	2	1	2025-11-04 21:22:39.681384	2025-11-05 07:43:32.522138	\N	\N	f	\N	t	4	t
103	https://www.r4.com/contacto	2	1	2025-11-04 21:22:42.153914	2025-11-05 07:43:34.934435	\N	\N	f	\N	t	4	t
104	https://www.r4.com/fondos-de-inversion	2	1	2025-11-04 21:22:43.416354	2025-11-05 07:43:36.12529	\N	\N	f	\N	t	4	t
105	https://www.r4.com/broker-online/herramientas	2	1	2025-11-04 21:22:44.677843	2025-11-05 07:43:37.322553	\N	\N	f	\N	t	4	t
106	https://www.r4.com/fondos-de-inversion/servicios/ahorro-periodico	2	1	2025-11-04 21:22:45.964712	2025-11-05 07:43:38.493657	\N	\N	f	\N	t	4	t
107	https://www.r4.com/que-necesitas/servicios-bancarios	2	1	2025-11-04 21:22:47.214361	2025-11-05 07:43:39.69194	\N	\N	f	\N	t	4	t
108	https://www.r4.com/normativa	2	1	2025-11-04 21:22:48.447102	2025-11-05 07:43:40.864271	\N	\N	f	\N	t	4	t
109	https://www.r4.com/que-necesitas/formacion	2	1	2025-11-04 21:22:49.647947	2025-11-05 07:43:42.053436	\N	\N	f	\N	t	4	t
110	https://www.r4.com/que-necesitas/formacion/boletines	2	1	2025-11-04 21:22:50.862932	2025-11-05 07:43:43.236031	\N	\N	f	\N	t	4	t
111	https://www.r4.com/que-necesitas/app-renta4	2	1	2025-11-04 21:22:52.130376	2025-11-05 07:43:44.370009	\N	\N	f	\N	t	4	t
113	https://www.r4.com/articulos-y-analisis/area-prensa	2	1	2025-11-04 21:22:54.938547	2025-11-05 07:43:46.836279	\N	\N	f	\N	t	4	t
115	https://www.r4.com/que-necesitas/compromiso-social	2	1	2025-11-04 21:22:57.447823	2025-11-05 07:43:49.160558	\N	\N	f	\N	t	4	t
116	https://www.r4.com/hazte-cliente	2	1	2025-11-04 21:22:58.661256	2025-11-05 07:43:50.387436	\N	\N	f	\N	t	4	t
117	https://www.r4.com/normativa/tablon-de-anuncios	2	1	2025-11-04 21:22:59.91855	2025-11-05 07:43:51.594412	\N	\N	f	\N	t	4	t
118	https://www.r4.com/normativa/aviso-legal	2	1	2025-11-04 21:23:01.153697	2025-11-05 07:43:52.788399	\N	\N	f	\N	t	4	t
119	https://www.r4.com/normativa/politica-privacidad	2	1	2025-11-04 21:23:02.351298	2025-11-05 07:43:53.974773	\N	\N	f	\N	t	4	t
120	https://www.r4.com/normativa/politica-cookies	2	1	2025-11-04 21:23:03.559468	2025-11-05 07:43:55.171041	\N	\N	f	\N	t	4	t
141	https://www.r4.com/planes-de-pensiones/categorias/planes-de-pensiones-renta-fija	20	2	2025-11-04 21:23:30.089783	2025-11-05 07:44:25.072973	\N	\N	f	\N	t	4	t
142	https://www.r4.com/planes-de-pensiones/categorias/planes-de-pensiones-renta-variable	20	2	2025-11-04 21:23:32.300365	2025-11-05 07:44:27.413056	\N	\N	f	\N	t	4	t
143	https://www.r4.com/planes-de-pensiones/categorias/planes-de-pensiones-mixtos	20	2	2025-11-04 21:23:34.580352	2025-11-05 07:44:28.773714	\N	\N	f	\N	t	4	t
144	https://www.r4.com/fondos-de-inversion/tipos-de-fondos-de-inversion	20	2	2025-11-04 21:23:35.94099	2025-11-05 07:44:30.153648	\N	\N	f	\N	t	4	t
145	https://www.r4.com/fondos-de-inversion/cuando-entrar-en-un-fondo-de-inversion	20	2	2025-11-04 21:23:37.353206	2025-11-05 07:44:31.358199	\N	\N	f	\N	t	4	t
146	https://www.r4.com/fondos-de-inversion/fiscalidad-tributacion-fondos-de-inversion	20	2	2025-11-04 21:23:38.623167	2025-11-05 07:44:32.485047	\N	\N	f	\N	t	4	t
147	https://www.r4.com/fondos-de-inversion/como-funciona-un-fondo-de-inversion	20	2	2025-11-04 21:23:39.929494	2025-11-05 07:44:33.690149	\N	\N	f	\N	t	4	t
148	https://www.r4.com/fondos-de-inversion/los-mejores-fondos-de-inversion-como-identificarlos	20	2	2025-11-04 21:23:41.205857	2025-11-05 07:44:34.876224	\N	\N	f	\N	t	4	t
149	https://www.r4.com/fondos-de-inversion/donde-contratar-fondos-de-inversion	20	2	2025-11-04 21:23:42.475432	2025-11-05 07:44:36.074366	\N	\N	f	\N	t	4	t
150	https://www.r4.com/fondos-de-inversion/riesgos-de-los-fondos-de-inversion	20	2	2025-11-04 21:23:43.77295	2025-11-05 07:44:37.236524	\N	\N	f	\N	t	4	t
151	https://www.r4.com/fondos-de-inversion/comisiones-fondos-de-inversion	20	2	2025-11-04 21:23:45.058916	2025-11-05 07:44:38.415645	\N	\N	f	\N	t	4	t
152	https://www.r4.com/planes-de-pensiones/como-funciona-un-plan-de-pensiones	20	2	2025-11-04 21:23:46.335187	2025-11-05 07:44:39.61869	\N	\N	f	\N	t	4	t
153	https://www.r4.com/planes-de-pensiones/como-elegir-un-plan-de-pensiones	20	2	2025-11-04 21:23:47.591322	2025-11-05 07:44:40.810193	\N	\N	f	\N	t	4	t
154	https://www.r4.com/planes-de-pensiones/que-es-una-epsv	20	2	2025-11-04 21:23:48.904811	2025-11-05 07:44:41.995889	\N	\N	f	\N	t	4	t
155	https://www.r4.com/planes-de-pensiones/mejores-planes-de-pensiones	20	2	2025-11-04 21:23:50.27434	2025-11-05 07:44:44.208882	\N	\N	f	\N	t	4	t
156	https://www.r4.com/planes-de-pensiones/rescate-planes-de-pensiones	20	2	2025-11-04 21:23:51.544839	2025-11-05 07:44:45.396082	\N	\N	f	\N	t	4	t
157	https://www.r4.com/planes-de-pensiones/rentabilidad-planes-de-pensiones	20	2	2025-11-04 21:23:52.874618	2025-11-05 07:44:46.561119	\N	\N	f	\N	t	4	t
158	https://www.r4.com/planes-de-pensiones/tipos-planes-de-pensiones	20	2	2025-11-04 21:23:54.243174	2025-11-05 07:44:47.717892	\N	\N	f	\N	t	4	t
159	https://www.r4.com/planes-de-pensiones/aportacion-maxima-planes-de-pensiones	20	2	2025-11-04 21:23:55.677182	2025-11-05 07:44:48.855613	\N	\N	f	\N	t	4	t
160	https://www.r4.com/fondos-de-inversion/plataforma-fondotop	21	2	2025-11-04 21:23:57.068933	2025-11-05 07:44:50.047734	\N	\N	f	\N	t	4	t
214	https://www.r4.com/fondos-de-inversion/traspaso-de-fondos-de-inversion	29	2	2025-11-04 21:25:05.569601	2025-11-05 07:45:58.758958	\N	\N	f	\N	t	4	t
259	https://www.r4.com/fondos-de-inversion/que-es-un-fondo-de-inversion	30	2	2025-11-04 21:26:18.16789	2025-11-05 07:47:01.123243	\N	\N	f	\N	t	4	t
284	https://www.r4.com/planes-de-pensiones/comisiones-planes-de-pensiones	31	2	2025-11-04 21:27:00.465435	2025-11-05 07:47:33.674047	\N	\N	f	\N	t	4	t
285	https://www.r4.com/planes-de-pensiones/traspaso-planes-de-pensiones	31	2	2025-11-04 21:27:01.599417	2025-11-05 07:47:34.844415	\N	\N	f	\N	t	4	t
287	https://www.r4.com/planes-de-pensiones/fiscalidad-planes-de-pensiones	31	2	2025-11-04 21:27:03.865351	2025-11-05 07:47:37.32114	\N	\N	f	\N	t	4	t
292	https://www.r4.com/broker-online/productos-de-inversion	32	2	2025-11-04 21:27:09.57442	2025-11-05 07:47:43.105944	\N	\N	f	\N	t	4	t
295	https://www.r4.com/broker-online/productos-de-inversion/futuros	33	2	2025-11-04 21:27:13.035797	2025-11-05 07:47:46.664291	\N	\N	f	\N	t	4	t
297	https://www.r4.com/broker-online/productos-de-inversion/forex/futuros-xrolling	33	2	2025-11-04 21:27:15.38659	2025-11-05 07:47:48.997521	\N	\N	f	\N	t	4	t
298	https://www.r4.com/broker-online/productos-de-inversion/bolsa/empezar-a-operar-en-bolsa	33	2	2025-11-04 21:27:16.529081	2025-11-05 07:47:50.144268	\N	\N	f	\N	t	4	t
299	https://www.r4.com/normativa/politica-privacidad/politica-privacidad-noclientes	33	2	2025-11-04 21:27:17.669181	2025-11-05 07:47:51.355935	\N	\N	f	\N	t	4	t
302	https://www.r4.com/fondos-de-inversion/servicios/multidivisa	34	2	2025-11-04 21:27:22.26147	2025-11-05 07:47:54.954379	\N	\N	f	\N	t	4	t
303	https://www.r4.com/que-necesitas/formacion/empezar-invertir	34	2	2025-11-04 21:27:23.412634	2025-11-05 07:47:56.163155	\N	\N	f	\N	t	4	t
304	https://www.r4.com/broker-online/productos-de-inversion/bolsa/que-es-la-bolsa	34	2	2025-11-04 21:27:24.542588	2025-11-05 07:47:57.385323	\N	\N	f	\N	t	4	t
305	https://www.r4.com/broker-online/productos-de-inversion/bolsa/traspaso-carteras-valores	34	2	2025-11-04 21:27:25.676808	2025-11-05 07:47:58.543569	\N	\N	f	\N	t	4	t
336	https://www.r4.com/broker-online/productos-de-inversion/etfs/que-son-etfs	35	2	2025-11-04 21:28:01.143229	2025-11-05 07:48:35.723495	\N	\N	f	\N	t	4	t
340	https://www.r4.com/broker-online/productos-de-inversion/warrants/que-son-warrants	38	2	2025-11-04 21:28:05.996804	2025-11-05 07:48:40.874992	\N	\N	f	\N	t	4	t
341	https://www.r4.com/serviciosr4/boletin-warrants	38	2	2025-11-04 21:28:07.175684	2025-11-05 07:48:42.131287	\N	\N	f	\N	t	4	t
483	https://www.r4.com/que-necesitas/tarjetas-de-pago	107	2	2025-11-04 21:31:31.819373	2025-11-05 07:52:00.39638	\N	\N	f	\N	t	4	t
484	https://www.r4.com/que-necesitas/servicios-bancarios/bizum	107	2	2025-11-04 21:31:33.156026	2025-11-05 07:52:01.823326	\N	\N	f	\N	t	4	t
485	https://www.r4.com/normativa/normativa-mifid	108	2	2025-11-04 21:31:35.096783	2025-11-05 07:52:03.082583	\N	\N	f	\N	t	4	t
486	https://www.r4.com/normativa/codigo-lei	108	2	2025-11-04 21:31:36.930641	2025-11-05 07:52:04.344397	\N	\N	f	\N	t	4	t
487	https://www.r4.com/normativa/canal-denuncias	108	2	2025-11-04 21:31:38.069435	2025-11-05 07:52:05.549228	\N	\N	f	\N	t	4	t
489	https://www.r4.com/que-necesitas/formacion/conferencias-seminarios	109	2	2025-11-04 21:31:40.969391	2025-11-05 07:52:08.72557	\N	\N	f	\N	t	4	t
490	https://www.r4.com/que-necesitas/formacion/webinars	109	2	2025-11-04 21:31:43.013257	2025-11-05 07:52:09.919252	\N	\N	f	\N	t	4	t
491	https://www.r4.com/que-necesitas/formacion/conferencias-multigestora	109	2	2025-11-04 21:31:44.193905	2025-11-05 07:52:12.019786	\N	\N	f	\N	t	4	t
492	https://www.r4.com/que-necesitas/formacion/guias-inversor	109	2	2025-11-04 21:31:45.356206	2025-11-05 07:52:13.188031	\N	\N	f	\N	t	4	t
493	https://www.r4.com/que-necesitas/formacion/diccionario	109	2	2025-11-04 21:31:46.510909	2025-11-05 07:52:14.348608	\N	\N	f	\N	t	4	t
494	https://www.r4.com/que-necesitas/formacion/tutoriales	109	2	2025-11-04 21:31:48.941471	2025-11-05 07:52:15.660445	\N	\N	f	\N	t	4	t
497	https://www.r4.com/academiar4/otros-productos-inversion	109	2	2025-11-04 21:31:52.411511	2025-11-05 07:52:19.288646	\N	\N	f	\N	t	4	t
499	https://www.r4.com/serviciosr4/cursos-finanzas-gratis	110	2	2025-11-04 21:31:55.75178	2025-11-05 07:52:22.002541	\N	\N	f	\N	t	4	t
500	https://www.r4.com/serviciosr4/boletin-analisis-tecnico	110	2	2025-11-04 21:31:56.869583	2025-11-05 07:52:23.132722	\N	\N	f	\N	t	4	t
505	https://www.r4.com/serviciosr4/descarga-gratis-guia-que-son-etfs	110	2	2025-11-04 21:32:03.723994	2025-11-05 07:52:29.373603	\N	\N	f	\N	t	4	t
535	https://www.r4.com/que-necesitas/quieres-mas/inversion-para-todos	115	2	2025-11-04 21:32:48.237009	2025-11-05 07:53:13.294487	\N	\N	f	\N	t	4	t
536	https://www.r4.com/que-necesitas/formacion/slow-finance	115	2	2025-11-04 21:32:49.475984	2025-11-05 07:53:14.526135	\N	\N	f	\N	t	4	t
541	https://www.r4.com/normativa/politica-privacidad/politica-privacidad-clientes	119	2	2025-11-04 21:32:55.522672	2025-11-05 07:53:20.554461	\N	\N	f	\N	t	4	t
542	https://www.r4.com/normativa/politica-privacidad/politica-privacidad-app	119	2	2025-11-04 21:32:56.778572	2025-11-05 07:53:21.793595	\N	\N	f	\N	t	4	t
561	https://www.r4.com/fondos-de-inversion/cursos-fondo-de-inversion	147	3	2025-11-04 21:33:24.288958	2025-11-05 07:53:47.546779	\N	\N	f	\N	t	4	t
562	https://www.r4.com/fondos-de-inversion/plataforma-fondotop/gestoras-internacionales	149	3	2025-11-04 21:33:25.471865	2025-11-05 07:53:48.741333	\N	\N	f	\N	t	4	t
578	https://www.r4.com/broker-online/productos-de-inversion/futuros/que-son-futuros	292	3	2025-11-04 21:33:48.307716	2025-11-05 07:54:09.443486	\N	\N	f	\N	t	4	t
579	https://www.r4.com/broker-online/productos-de-inversion/opciones/que-son-opciones	292	3	2025-11-04 21:33:49.599202	2025-11-05 07:54:10.718129	\N	\N	f	\N	t	4	t
580	https://www.r4.com/broker-online/productos-de-inversion/forex	297	3	2025-11-04 21:33:50.99252	2025-11-05 07:54:11.900775	\N	\N	f	\N	t	4	t
581	https://www.r4.com/serviciosr4/broker-online-para-invertir-en-bolsa-con-ventaja	298	3	2025-11-04 21:33:52.352697	2025-11-05 07:54:13.186343	\N	\N	f	\N	t	4	t
601	https://www.r4.com/que-necesitas/formacion/empezar-invertir/como-invertir-mi-dinero	303	3	2025-11-04 21:34:19.752752	2025-11-05 07:54:38.573149	\N	\N	f	\N	t	4	t
602	https://www.r4.com/que-necesitas/formacion/empezar-invertir/como-rentabilizar-mis-ahorros	303	3	2025-11-04 21:34:21.00531	2025-11-05 07:54:39.707657	\N	\N	f	\N	t	4	t
604	https://www.r4.com/que-necesitas/formacion/empezar-invertir/beneficios-inversion-largo-plazo	303	3	2025-11-04 21:34:23.47809	2025-11-05 07:54:41.994789	\N	\N	f	\N	t	4	t
1034	https://www.r4.com/que-necesitas/formacion/empezar-invertir/cuanto-dinero-necesito-para-invertir/invertir-10000-euros	603	4	2025-11-04 21:45:08.8369	2025-11-05 08:05:38.720257	\N	\N	f	\N	t	4	t
671	https://www.r4.com/columnas-de-autores/vive-la-pasion-de-los-mercados	405	3	2025-11-04 21:35:45.987984	2025-11-05 07:56:10.348341	\N	\N	f	\N	t	4	t
778	https://www.r4.com/que-necesitas/formacion/diccionario/que-es-una-accion	493	3	2025-11-04 21:38:33.884078	2025-11-05 07:59:06.35546	\N	\N	f	\N	t	4	t
780	https://www.r4.com/que-necesitas/formacion/diccionario/que-es-un-dividendo	493	3	2025-11-04 21:38:37.128492	2025-11-05 07:59:08.711302	\N	\N	f	\N	t	4	t
1191	https://www.r4.com/seguros	796	4	2025-11-04 21:48:58.260442	2025-11-05 08:09:18.02907	\N	\N	f	\N	t	4	t
1035	https://www.r4.com/servicios-gestion/planificacion-financiera	604	4	2025-11-04 21:45:10.021533	2025-11-05 08:05:40.013232	\N	\N	f	\N	t	4	t
1174	https://www.r4.com/serviciosr4/broker-online-con-las-mejores-tarifas	778	4	2025-11-04 21:48:31.610714	2025-11-05 08:08:50.430319	\N	\N	f	\N	t	4	t
1188	https://www.r4.com/serviciosr4/acciones-internacionales	792	4	2025-11-04 21:48:54.237481	2025-11-05 08:09:13.662955	\N	\N	f	\N	t	4	t
1261	https://www.r4.com/servicios-gestion	837	4	2025-11-04 21:51:02.438239	2025-11-05 08:11:14.085742	\N	\N	f	\N	t	4	t
32	https://www.r4.com/planes-de-pensiones/plan-de-pensiones-autonomos	2	1	2025-11-04 21:21:17.144754	2025-11-05 07:42:10.935802	\N	\N	f	\N	t	4	t
80	https://www.r4.com/soluciones-easy/carteras-easy	2	1	2025-11-04 21:22:14.078551	2025-11-05 07:43:06.526798	\N	\N	f	\N	t	4	t
114	https://www.r4.com/que-necesitas/formacion/ahorrador-a-inversor	2	1	2025-11-04 21:22:56.24647	2025-11-05 07:43:48.001815	\N	\N	f	\N	t	4	t
172	https://www.r4.com/fondos-de-inversion/rentabilidad-fondos-de-inversion	22	2	2025-11-04 21:24:12.285862	2025-11-05 07:45:04.399538	\N	\N	f	\N	t	4	t
283	https://www.r4.com/planes-de-pensiones/que-es-un-plan-de-pensiones	31	2	2025-11-04 21:26:58.404864	2025-11-05 07:47:32.494691	\N	\N	f	\N	t	4	t
296	https://www.r4.com/broker-online/productos-de-inversion/opciones	33	2	2025-11-04 21:27:14.229186	2025-11-05 07:47:47.838325	\N	\N	f	\N	t	4	t
337	https://www.r4.com/broker-online/productos-de-inversion/cfds/que-son-cfds	36	2	2025-11-04 21:28:02.315981	2025-11-05 07:48:37.052684	\N	\N	f	\N	t	4	t
476	https://www.r4.com/que-necesitas/soluciones-digitales/asesor-digital-inteligente-fondos	100	2	2025-11-04 21:31:22.448429	2025-11-05 07:51:51.95482	\N	\N	f	\N	t	4	t
779	https://www.r4.com/que-necesitas/formacion/diccionario/que-es-un-broker	493	3	2025-11-04 21:38:35.099128	2025-11-05 07:59:07.534234	\N	\N	f	\N	t	4	t
4225	https://www.r4.com/normativa/guia-seguridad	1746	6	2025-11-05 08:35:10.590382	\N	\N	\N	f	\N	t	4	t
\.


--
-- Data for Name: health_snapshots; Type: TABLE DATA; Schema: public; Owner: jesusramos
--

COPY public.health_snapshots (id, snapshot_date, health_score, total_urls, ok_urls, broken_urls, redirect_urls, error_urls) FROM stdin;
\.


--
-- Data for Name: notification_preferences; Type: TABLE DATA; Schema: public; Owner: jesusramos
--

COPY public.notification_preferences (id, user_name, email, enable_email, enable_desktop, enable_in_app, created_at, updated_at) FROM stdin;
1	José Ramos	ramos.membrive@gmail.com	t	t	t	2025-10-29 11:52:26	2025-10-29 11:52:26
\.


--
-- Data for Name: pending_alerts; Type: TABLE DATA; Schema: public; Owner: jesusramos
--

COPY public.pending_alerts (id, task_type_id, due_date, generated_at, dismissed, dismissed_at) FROM stdin;
1	1	2025-10-29	2025-10-29 10:37:44	f	\N
2	1	2026-01-01	2025-10-29 10:41:34	f	\N
3	3	2026-01-01	2025-10-29 10:41:34	f	\N
4	4	2026-01-01	2025-10-29 10:41:34	f	\N
5	5	2026-01-01	2025-10-29 10:41:34	f	\N
6	6	2026-01-01	2025-10-29 10:41:34	f	\N
7	7	2026-01-01	2025-10-29 10:41:34	f	\N
8	8	2026-01-01	2025-10-29 10:41:34	f	\N
18	2	2025-10-29	2025-10-29 12:18:46	f	\N
19	3	2025-10-29	2025-10-29 12:18:46	f	\N
20	4	2025-10-29	2025-10-29 12:18:46	f	\N
21	5	2025-10-29	2025-10-29 12:18:46	f	\N
22	6	2025-10-29	2025-10-29 12:18:46	f	\N
23	7	2025-10-29	2025-10-29 12:18:46	f	\N
24	8	2025-10-29	2025-10-29 12:18:46	f	\N
\.


--
-- Data for Name: quality_check_batches; Type: TABLE DATA; Schema: public; Owner: jesusramos
--

COPY public.quality_check_batches (id, batch_type, status, total_urls, processed_urls, successful_checks, failed_checks, started_at, completed_at, created_by, error_message) FROM stdin;
\.


--
-- Data for Name: quality_check_config; Type: TABLE DATA; Schema: public; Owner: jesusramos
--

COPY public.quality_check_config (id, user_id, check_type, enabled, run_after_crawl, created_at, updated_at, scope) FROM stdin;
7	1	spell_check	t	t	2025-11-04 19:16:52.314342	2025-11-04 21:20:04.44114	priority
5	1	broken_links	t	t	2025-11-04 19:16:52.314342	2025-11-04 21:20:04.441679	priority
6	1	image_quality	t	t	2025-11-04 19:16:52.314342	2025-11-04 21:20:04.443317	priority
\.


--
-- Data for Name: quality_checks; Type: TABLE DATA; Schema: public; Owner: jesusramos
--

COPY public.quality_checks (id, section_id, check_type, status, score, message, details, issues_found, execution_time_ms, checked_at, created_at, discovered_url_id) FROM stdin;
2	\N	image_quality	ok	100	All 19 images are working	{"total_images": 19, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4363	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	17
3	\N	image_quality	ok	100	All 19 images are working	{"total_images": 19, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4365	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	18
4	\N	image_quality	ok	100	All 19 images are working	{"total_images": 19, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4563	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	16
5	\N	image_quality	ok	100	All 26 images are working	{"total_images": 26, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6257	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	2
6	\N	image_quality	ok	100	All 29 images are working	{"total_images": 29, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6643	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	10
7	\N	image_quality	ok	100	All 30 images are working	{"total_images": 30, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	7167	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	15
8	\N	image_quality	ok	100	All 34 images are working	{"total_images": 34, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	7800	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	13
9	\N	image_quality	ok	100	All 35 images are working	{"total_images": 35, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	8085	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	11
10	\N	image_quality	ok	100	All 33 images are working	{"total_images": 33, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	7940	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	14
11	\N	image_quality	ok	100	All 38 images are working	{"total_images": 38, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	8231	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	12
12	\N	image_quality	ok	100	All 19 images are working	{"total_images": 19, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4675	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	19
13	\N	image_quality	ok	100	All 26 images are working	{"total_images": 26, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	7007	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	20
14	\N	image_quality	ok	100	All 23 images are working	{"total_images": 23, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5756	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	29
15	\N	image_quality	ok	100	All 35 images are working	{"total_images": 35, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	8334	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	26
16	\N	image_quality	ok	100	All 22 images are working	{"total_images": 22, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5529	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	31
17	\N	image_quality	ok	100	All 47 images are working	{"total_images": 47, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	10979	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	24
18	\N	image_quality	ok	100	All 46 images are working	{"total_images": 46, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	10448	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	25
19	\N	image_quality	ok	100	All 53 images are working	{"total_images": 53, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	12224	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	23
20	\N	image_quality	ok	100	All 59 images are working	{"total_images": 59, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	13667	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	22
21	\N	image_quality	ok	100	All 19 images are working	{"total_images": 19, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4547	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	33
22	\N	image_quality	ok	100	All 50 images are working	{"total_images": 50, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	11330	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	27
23	\N	image_quality	ok	100	All 48 images are working	{"total_images": 48, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	12137	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	28
24	\N	image_quality	ok	100	All 23 images are working	{"total_images": 23, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5266	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	34
25	\N	image_quality	ok	100	All 21 images are working	{"total_images": 21, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4789	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	37
26	\N	image_quality	ok	100	All 27 images are working	{"total_images": 27, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6336	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	68
27	\N	image_quality	ok	100	All 26 images are working	{"total_images": 26, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6186	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	36
28	\N	image_quality	ok	100	All 25 images are working	{"total_images": 25, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5882	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	38
29	\N	image_quality	ok	100	All 27 images are working	{"total_images": 27, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6445	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	39
30	\N	image_quality	ok	100	All 39 images are working	{"total_images": 39, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	9552	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	35
31	\N	image_quality	ok	100	All 23 images are working	{"total_images": 23, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5498	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	71
32	\N	image_quality	ok	100	All 32 images are working	{"total_images": 32, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	7725	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	69
33	\N	image_quality	ok	100	All 28 images are working	{"total_images": 28, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6920	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	70
34	\N	image_quality	ok	100	All 26 images are working	{"total_images": 26, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6151	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	81
35	\N	image_quality	ok	100	All 22 images are working	{"total_images": 22, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5052	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	84
36	\N	image_quality	ok	100	All 30 images are working	{"total_images": 30, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	7421	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	79
37	\N	image_quality	ok	100	All 21 images are working	{"total_images": 21, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4735	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	85
38	\N	image_quality	ok	100	All 30 images are working	{"total_images": 30, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	7245	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	83
39	\N	image_quality	ok	100	All 24 images are working	{"total_images": 24, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5562	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	86
40	\N	image_quality	ok	100	All 24 images are working	{"total_images": 24, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5721	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	88
41	\N	image_quality	ok	100	All 38 images are working	{"total_images": 38, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	9257	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	82
42	\N	image_quality	ok	100	All 28 images are working	{"total_images": 28, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	7069	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	89
43	\N	image_quality	ok	100	All 20 images are working	{"total_images": 20, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4983	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	93
44	\N	image_quality	ok	100	All 14 images are working	{"total_images": 14, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	3762	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	103
45	\N	image_quality	ok	100	All 21 images are working	{"total_images": 21, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5376	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	90
46	\N	image_quality	ok	100	All 16 images are working	{"total_images": 16, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4036	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	101
47	\N	image_quality	ok	100	All 23 images are working	{"total_images": 23, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5731	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	100
48	\N	image_quality	ok	100	All 20 images are working	{"total_images": 20, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5100	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	105
49	\N	image_quality	ok	100	All 12 images are working	{"total_images": 12, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	3010	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	108
50	\N	image_quality	ok	100	All 18 images are working	{"total_images": 18, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4415	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	107
51	\N	image_quality	ok	100	All 22 images are working	{"total_images": 22, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5509	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	106
52	\N	image_quality	ok	100	All 29 images are working	{"total_images": 29, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	7451	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	104
53	\N	image_quality	ok	100	All 19 images are working	{"total_images": 19, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5337	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	109
54	\N	image_quality	ok	100	All 22 images are working	{"total_images": 22, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5527	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	110
55	\N	image_quality	ok	100	All 23 images are working	{"total_images": 23, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5882	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	114
56	\N	image_quality	ok	100	All 12 images are working	{"total_images": 12, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	3013	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	117
57	\N	image_quality	ok	100	All 12 images are working	{"total_images": 12, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	2976	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	118
58	\N	image_quality	ok	100	All 21 images are working	{"total_images": 21, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5637	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	115
59	\N	image_quality	ok	100	All 12 images are working	{"total_images": 12, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	3254	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	119
60	\N	image_quality	ok	100	All 25 images are working	{"total_images": 25, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6884	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	111
61	\N	image_quality	ok	100	All 35 images are working	{"total_images": 35, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	8672	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	80
62	\N	image_quality	ok	100	All 30 images are working	{"total_images": 30, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	7858	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	32
63	\N	image_quality	ok	100	All 28 images are working	{"total_images": 28, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	7631	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	113
64	\N	image_quality	ok	100	All 27 images are working	{"total_images": 27, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	7529	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	116
65	\N	image_quality	ok	100	All 12 images are working	{"total_images": 12, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4562	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	120
66	\N	image_quality	ok	100	All 19 images are working • 4 external images skipped	{"total_images": 19, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 4}	0	5868	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	141
67	\N	image_quality	ok	100	All 18 images are working • 4 external images skipped	{"total_images": 18, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 4}	0	5512	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	142
68	\N	image_quality	ok	100	All 24 images are working	{"total_images": 24, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	7289	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	293
69	\N	image_quality	ok	100	All 26 images are working	{"total_images": 26, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	7780	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	297
70	\N	image_quality	ok	100	All 28 images are working	{"total_images": 28, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	8574	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	8
71	\N	image_quality	ok	100	All 21 images are working • 4 external images skipped	{"total_images": 21, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 4}	0	6397	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	143
72	\N	image_quality	ok	100	All 19 images are working	{"total_images": 19, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5006	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	145
73	\N	image_quality	ok	100	All 30 images are working	{"total_images": 30, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	8992	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	9
74	\N	image_quality	ok	100	All 24 images are working	{"total_images": 24, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6638	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	144
75	\N	image_quality	ok	100	All 17 images are working	{"total_images": 17, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4218	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	146
76	\N	image_quality	ok	100	All 209 images are working	{"total_images": 209, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	45997	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	30
77	\N	image_quality	ok	100	All 19 images are working	{"total_images": 19, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4429	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	147
78	\N	image_quality	ok	100	All 17 images are working	{"total_images": 17, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4282	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	148
79	\N	image_quality	ok	100	All 19 images are working	{"total_images": 19, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4700	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	150
80	\N	image_quality	ok	100	All 18 images are working	{"total_images": 18, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4569	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	152
81	\N	image_quality	ok	100	All 24 images are working	{"total_images": 24, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6350	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	149
82	\N	image_quality	ok	100	All 22 images are working	{"total_images": 22, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5507	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	153
83	\N	image_quality	ok	100	All 21 images are working	{"total_images": 21, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5471	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	154
84	\N	image_quality	ok	100	All 28 images are working	{"total_images": 28, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	7340	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	151
85	\N	image_quality	ok	100	All 20 images are working	{"total_images": 20, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5129	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	155
86	\N	image_quality	ok	100	All 20 images are working	{"total_images": 20, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5085	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	156
87	\N	image_quality	ok	100	All 21 images are working	{"total_images": 21, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5336	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	157
88	\N	image_quality	ok	100	All 17 images are working	{"total_images": 17, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4760	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	159
89	\N	image_quality	ok	100	All 19 images are working	{"total_images": 19, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5877	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	158
90	\N	image_quality	ok	100	All 22 images are working	{"total_images": 22, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6036	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	160
91	\N	image_quality	ok	100	All 18 images are working	{"total_images": 18, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5156	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	284
92	\N	image_quality	ok	100	All 17 images are working	{"total_images": 17, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4677	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	287
93	\N	image_quality	ok	100	All 23 images are working	{"total_images": 23, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6215	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	259
94	\N	image_quality	ok	100	All 18 images are working	{"total_images": 18, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5203	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	285
95	\N	image_quality	ok	100	All 12 images are working	{"total_images": 12, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	3180	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	299
96	\N	image_quality	ok	100	All 26 images are working	{"total_images": 26, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	7110	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	214
97	\N	image_quality	ok	100	All 24 images are working	{"total_images": 24, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6658	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	292
98	\N	image_quality	ok	100	All 17 images are working	{"total_images": 17, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4430	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	302
99	\N	image_quality	ok	100	All 10 images are working	{"total_images": 10, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	2607	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	341
100	\N	image_quality	ok	100	All 28 images are working	{"total_images": 28, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	7577	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	295
101	\N	image_quality	ok	100	All 27 images are working	{"total_images": 27, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	7284	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	298
102	\N	image_quality	ok	100	All 22 images are working	{"total_images": 22, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5792	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	303
103	\N	image_quality	ok	100	All 22 images are working	{"total_images": 22, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5820	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	336
104	\N	image_quality	ok	100	All 25 images are working	{"total_images": 25, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6470	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	305
105	\N	image_quality	ok	100	All 27 images are working	{"total_images": 27, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	7109	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	304
106	\N	image_quality	ok	100	All 11 images are working	{"total_images": 11, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	2884	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	487
107	\N	image_quality	ok	100	All 26 images are working	{"total_images": 26, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6797	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	340
108	\N	image_quality	error	0	Found 1 broken image(s)	{"total_images": 24, "broken_images": 1, "hotlink_protected": 0, "broken_images_list": [{"url": "https://www.r4.com/content/dam/rentabanco/r4/imagenes/cc11-banner-simple/CC11-busqueda-en-ordenador.jpg.transform/medium/img.jpg", "status": 404}], "hotlink_protected_list": [], "external_images_skipped": 0}	1	6125	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	483
109	\N	image_quality	ok	100	All 20 images are working	{"total_images": 20, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4965	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	485
110	\N	image_quality	ok	100	All 20 images are working	{"total_images": 20, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5147	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	486
111	\N	image_quality	ok	100	All 22 images are working	{"total_images": 22, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5758	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	484
112	\N	image_quality	ok	100	All 18 images are working	{"total_images": 18, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4695	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	489
113	\N	image_quality	ok	100	All 15 images are working	{"total_images": 15, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4017	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	491
114	\N	image_quality	ok	100	All 5 images are working	{"total_images": 5, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	1664	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	505
115	\N	image_quality	ok	100	All 12 images are working	{"total_images": 12, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	3593	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	493
116	\N	image_quality	ok	100	All 17 images are working	{"total_images": 17, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4679	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	492
117	\N	image_quality	ok	100	All 10 images are working	{"total_images": 10, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	3105	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	500
118	\N	image_quality	ok	100	All 24 images are working	{"total_images": 24, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6819	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	490
119	\N	image_quality	ok	100	All 16 images are working • 9 external images skipped	{"total_images": 16, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 9}	0	6155	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	494
120	\N	image_quality	ok	100	All 18 images are working	{"total_images": 18, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5312	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	499
121	\N	image_quality	ok	100	All 12 images are working	{"total_images": 12, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	3826	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	541
122	\N	image_quality	ok	100	All 21 images are working	{"total_images": 21, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6438	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	497
123	\N	image_quality	ok	100	All 13 images are working	{"total_images": 13, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	3934	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	542
124	\N	image_quality	ok	100	All 17 images are working	{"total_images": 17, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4913	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	172
125	\N	image_quality	ok	100	All 20 images are working	{"total_images": 20, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6527	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	535
126	\N	image_quality	ok	100	All 17 images are working	{"total_images": 17, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5127	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	283
127	\N	image_quality	ok	100	All 23 images are working	{"total_images": 23, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6866	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	536
128	\N	image_quality	ok	100	All 17 images are working	{"total_images": 17, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4725	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	561
129	\N	image_quality	ok	100	All 22 images are working	{"total_images": 22, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6641	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	296
130	\N	image_quality	ok	100	All 20 images are working	{"total_images": 20, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5959	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	476
131	\N	image_quality	ok	100	All 11 images are working	{"total_images": 11, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	3363	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	581
132	\N	image_quality	ok	100	All 20 images are working	{"total_images": 20, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6090	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	602
133	\N	image_quality	ok	100	All 22 images are working	{"total_images": 22, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6388	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	779
134	\N	image_quality	ok	100	All 20 images are working	{"total_images": 20, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5603	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	580
135	\N	image_quality	ok	100	All 19 images are working	{"total_images": 19, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5663	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	601
136	\N	image_quality	ok	100	All 34 images are working	{"total_images": 34, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	9583	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	337
137	\N	image_quality	ok	100	All 25 images are working	{"total_images": 25, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	7015	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	579
138	\N	image_quality	ok	100	All 18 images are working	{"total_images": 18, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5402	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	604
139	\N	image_quality	ok	100	All 11 images are working	{"total_images": 11, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	3097	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	1174
140	\N	image_quality	ok	100	All 23 images are working	{"total_images": 23, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6562	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	671
141	\N	image_quality	ok	100	All 23 images are working	{"total_images": 23, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6548	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	778
142	\N	image_quality	ok	100	All 18 images are working	{"total_images": 18, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5516	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	562
143	\N	image_quality	ok	100	All 22 images are working	{"total_images": 22, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	6333	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	780
144	\N	image_quality	ok	100	All 15 images are working	{"total_images": 15, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4265	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	1188
145	\N	image_quality	ok	100	All 15 images are working	{"total_images": 15, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	3883	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	1034
146	\N	image_quality	ok	100	All 27 images are working	{"total_images": 27, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	7145	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	578
147	\N	image_quality	ok	100	All 23 images are working	{"total_images": 23, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	5227	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	1261
148	\N	image_quality	ok	100	All 25 images are working	{"total_images": 25, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	4516	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	1191
149	\N	image_quality	ok	100	All 22 images are working	{"total_images": 22, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	3902	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	1035
150	\N	image_quality	ok	100	All 22 images are working	{"total_images": 22, "broken_images": 0, "hotlink_protected": 0, "broken_images_list": [], "hotlink_protected_list": [], "external_images_skipped": 0}	0	3727	2025-11-05 15:10:54.662037	2025-11-05 15:10:54.662037	4225
896	\N	spell_check	ok	100	No spelling errors found (656 words checked)	{"language": "es", "text_length": 7424, "total_words": 656, "max_text_length": 10000, "spelling_errors": []}	0	248	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	11
897	\N	spell_check	ok	100	No spelling errors found (524 words checked)	{"language": "es", "text_length": 6822, "total_words": 524, "max_text_length": 10000, "spelling_errors": []}	0	308	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	18
898	\N	spell_check	ok	100	No spelling errors found (788 words checked)	{"language": "es", "text_length": 10000, "total_words": 788, "max_text_length": 10000, "spelling_errors": []}	0	310	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	2
899	\N	spell_check	ok	100	No spelling errors found (750 words checked)	{"language": "es", "text_length": 10000, "total_words": 750, "max_text_length": 10000, "spelling_errors": []}	0	363	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	16
900	\N	spell_check	ok	100	No spelling errors found (721 words checked)	{"language": "es", "text_length": 8963, "total_words": 721, "max_text_length": 10000, "spelling_errors": []}	0	326	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	15
901	\N	spell_check	ok	100	No spelling errors found (495 words checked)	{"language": "es", "text_length": 6310, "total_words": 495, "max_text_length": 10000, "spelling_errors": []}	0	340	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	17
902	\N	spell_check	ok	100	No spelling errors found (636 words checked)	{"language": "es", "text_length": 7314, "total_words": 636, "max_text_length": 10000, "spelling_errors": []}	0	359	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	13
903	\N	spell_check	ok	100	No spelling errors found (703 words checked)	{"language": "es", "text_length": 7898, "total_words": 703, "max_text_length": 10000, "spelling_errors": []}	0	374	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	12
904	\N	spell_check	ok	100	No spelling errors found (851 words checked)	{"language": "es", "text_length": 10000, "total_words": 851, "max_text_length": 10000, "spelling_errors": []}	0	378	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	14
905	\N	spell_check	ok	100	No spelling errors found (812 words checked)	{"language": "es", "text_length": 10000, "total_words": 812, "max_text_length": 10000, "spelling_errors": []}	0	352	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	10
906	\N	spell_check	ok	100	No spelling errors found (492 words checked)	{"language": "es", "text_length": 6224, "total_words": 492, "max_text_length": 10000, "spelling_errors": []}	0	156	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	19
907	\N	spell_check	ok	100	No spelling errors found (777 words checked)	{"language": "es", "text_length": 10000, "total_words": 777, "max_text_length": 10000, "spelling_errors": []}	0	189	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	20
908	\N	spell_check	ok	100	No spelling errors found (539 words checked)	{"language": "es", "text_length": 10000, "total_words": 539, "max_text_length": 10000, "spelling_errors": []}	0	561	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	22
909	\N	spell_check	ok	100	No spelling errors found (720 words checked)	{"language": "es", "text_length": 10000, "total_words": 720, "max_text_length": 10000, "spelling_errors": []}	0	260	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	25
910	\N	spell_check	ok	100	No spelling errors found (736 words checked)	{"language": "es", "text_length": 10000, "total_words": 736, "max_text_length": 10000, "spelling_errors": []}	0	162	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	26
911	\N	spell_check	ok	100	No spelling errors found (685 words checked)	{"language": "es", "text_length": 8599, "total_words": 685, "max_text_length": 10000, "spelling_errors": []}	0	148	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	29
912	\N	spell_check	ok	100	No spelling errors found (708 words checked)	{"language": "es", "text_length": 10000, "total_words": 708, "max_text_length": 10000, "spelling_errors": []}	0	365	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	24
913	\N	spell_check	ok	100	No spelling errors found (686 words checked)	{"language": "es", "text_length": 10000, "total_words": 686, "max_text_length": 10000, "spelling_errors": []}	0	283	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	28
914	\N	spell_check	ok	100	No spelling errors found (718 words checked)	{"language": "es", "text_length": 10000, "total_words": 718, "max_text_length": 10000, "spelling_errors": []}	0	358	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	27
915	\N	spell_check	ok	100	No spelling errors found (583 words checked)	{"language": "es", "text_length": 10000, "total_words": 583, "max_text_length": 10000, "spelling_errors": []}	0	709	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	23
916	\N	spell_check	ok	100	No spelling errors found (558 words checked)	{"language": "es", "text_length": 6530, "total_words": 558, "max_text_length": 10000, "spelling_errors": []}	0	89	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	33
917	\N	spell_check	ok	100	No spelling errors found (802 words checked)	{"language": "es", "text_length": 10000, "total_words": 802, "max_text_length": 10000, "spelling_errors": []}	0	164	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	35
918	\N	spell_check	ok	100	No spelling errors found (734 words checked)	{"language": "es", "text_length": 10000, "total_words": 734, "max_text_length": 10000, "spelling_errors": []}	0	559	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	31
919	\N	spell_check	ok	100	No spelling errors found (792 words checked)	{"language": "es", "text_length": 10000, "total_words": 792, "max_text_length": 10000, "spelling_errors": []}	0	197	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	34
920	\N	spell_check	ok	100	No spelling errors found (677 words checked)	{"language": "es", "text_length": 8266, "total_words": 677, "max_text_length": 10000, "spelling_errors": []}	0	111	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	36
921	\N	spell_check	ok	100	No spelling errors found (843 words checked)	{"language": "es", "text_length": 10000, "total_words": 843, "max_text_length": 10000, "spelling_errors": []}	0	205	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	68
922	\N	spell_check	ok	100	No spelling errors found (349 words checked)	{"language": "es", "text_length": 4026, "total_words": 349, "max_text_length": 10000, "spelling_errors": []}	0	127	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	37
923	\N	spell_check	ok	100	No spelling errors found (576 words checked)	{"language": "es", "text_length": 6954, "total_words": 576, "max_text_length": 10000, "spelling_errors": []}	0	150	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	38
924	\N	spell_check	ok	100	No spelling errors found (722 words checked)	{"language": "es", "text_length": 9894, "total_words": 722, "max_text_length": 10000, "spelling_errors": []}	0	196	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	39
925	\N	spell_check	ok	100	No spelling errors found (777 words checked)	{"language": "es", "text_length": 10000, "total_words": 777, "max_text_length": 10000, "spelling_errors": []}	0	204	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	69
926	\N	spell_check	ok	100	No spelling errors found (737 words checked)	{"language": "es", "text_length": 9282, "total_words": 737, "max_text_length": 10000, "spelling_errors": []}	0	108	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	70
927	\N	spell_check	ok	100	No spelling errors found (803 words checked)	{"language": "es", "text_length": 10000, "total_words": 803, "max_text_length": 10000, "spelling_errors": []}	0	124	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	81
928	\N	spell_check	ok	100	No spelling errors found (558 words checked)	{"language": "es", "text_length": 7033, "total_words": 558, "max_text_length": 10000, "spelling_errors": []}	0	156	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	71
929	\N	spell_check	ok	100	No spelling errors found (417 words checked)	{"language": "es", "text_length": 5038, "total_words": 417, "max_text_length": 10000, "spelling_errors": []}	0	136	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	79
930	\N	spell_check	ok	100	No spelling errors found (560 words checked)	{"language": "es", "text_length": 6766, "total_words": 560, "max_text_length": 10000, "spelling_errors": []}	0	132	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	82
931	\N	spell_check	ok	100	No spelling errors found (460 words checked)	{"language": "es", "text_length": 5833, "total_words": 460, "max_text_length": 10000, "spelling_errors": []}	0	163	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	83
932	\N	spell_check	ok	100	No spelling errors found (252 words checked)	{"language": "es", "text_length": 3022, "total_words": 252, "max_text_length": 10000, "spelling_errors": []}	0	108	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	84
933	\N	spell_check	ok	100	No spelling errors found (293 words checked)	{"language": "es", "text_length": 3243, "total_words": 293, "max_text_length": 10000, "spelling_errors": []}	0	198	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	88
934	\N	spell_check	ok	100	No spelling errors found (178 words checked)	{"language": "es", "text_length": 2044, "total_words": 178, "max_text_length": 10000, "spelling_errors": []}	0	96	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	85
935	\N	spell_check	ok	100	No spelling errors found (305 words checked)	{"language": "es", "text_length": 3333, "total_words": 305, "max_text_length": 10000, "spelling_errors": []}	0	74	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	86
936	\N	spell_check	ok	100	No spelling errors found (231 words checked)	{"language": "es", "text_length": 2634, "total_words": 231, "max_text_length": 10000, "spelling_errors": []}	0	101	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	89
937	\N	spell_check	ok	100	No spelling errors found (378 words checked)	{"language": "es", "text_length": 4284, "total_words": 378, "max_text_length": 10000, "spelling_errors": []}	0	66	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	106
938	\N	spell_check	ok	100	No spelling errors found (204 words checked)	{"language": "es", "text_length": 2304, "total_words": 204, "max_text_length": 10000, "spelling_errors": []}	0	99	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	90
939	\N	spell_check	ok	100	No spelling errors found (608 words checked)	{"language": "es", "text_length": 7507, "total_words": 608, "max_text_length": 10000, "spelling_errors": []}	0	159	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	100
940	\N	spell_check	ok	100	No spelling errors found (395 words checked)	{"language": "es", "text_length": 4581, "total_words": 395, "max_text_length": 10000, "spelling_errors": []}	0	103	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	104
941	\N	spell_check	ok	100	No spelling errors found (285 words checked)	{"language": "es", "text_length": 3305, "total_words": 285, "max_text_length": 10000, "spelling_errors": []}	0	242	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	93
942	\N	spell_check	ok	100	No spelling errors found (311 words checked)	{"language": "es", "text_length": 3790, "total_words": 311, "max_text_length": 10000, "spelling_errors": []}	0	249	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	103
943	\N	spell_check	ok	100	No spelling errors found (311 words checked)	{"language": "es", "text_length": 4108, "total_words": 311, "max_text_length": 10000, "spelling_errors": []}	0	305	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	101
944	\N	spell_check	ok	100	No spelling errors found (384 words checked)	{"language": "es", "text_length": 4415, "total_words": 384, "max_text_length": 10000, "spelling_errors": []}	0	239	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	105
972	\N	spell_check	ok	100	No spelling errors found (455 words checked)	{"language": "es", "text_length": 5629, "total_words": 455, "max_text_length": 10000, "spelling_errors": []}	0	86	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	150
945	\N	spell_check	ok	99	Found 1 spelling error in 643 words	{"language": "es", "text_length": 10000, "total_words": 643, "max_text_length": 10000, "spelling_errors": [{"word": "encuentes", "context": "selección para que **encuentes** el mejor fondo", "position": 126, "sentence": "Los fondos favoritos de nuestros gestores Fondos de las mejores gestoras del mundo Un listado actualizado periódicamente Una selección para que encuentes el mejor fondo para ti Los mercados nunca están quietos: subidas de tipos, guerras, revoluciones tecnológicas, relaciones comerciales internacionales...", "suggestions": ["encuesten", "encentes", "encuentres"]}]}	1	4150	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	30
946	\N	spell_check	ok	100	No spelling errors found (377 words checked)	{"language": "es", "text_length": 4358, "total_words": 377, "max_text_length": 10000, "spelling_errors": []}	0	125	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	107
947	\N	spell_check	ok	100	No spelling errors found (328 words checked)	{"language": "es", "text_length": 3925, "total_words": 328, "max_text_length": 10000, "spelling_errors": []}	0	69	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	108
948	\N	spell_check	ok	100	No spelling errors found (281 words checked)	{"language": "es", "text_length": 3142, "total_words": 281, "max_text_length": 10000, "spelling_errors": []}	0	112	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	109
949	\N	spell_check	ok	100	No spelling errors found (286 words checked)	{"language": "es", "text_length": 3136, "total_words": 286, "max_text_length": 10000, "spelling_errors": []}	0	67	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	110
950	\N	spell_check	ok	100	No spelling errors found (376 words checked)	{"language": "es", "text_length": 4570, "total_words": 376, "max_text_length": 10000, "spelling_errors": []}	0	133	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	114
951	\N	spell_check	ok	100	No spelling errors found (784 words checked)	{"language": "es", "text_length": 10000, "total_words": 784, "max_text_length": 10000, "spelling_errors": []}	0	249	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	80
952	\N	spell_check	ok	100	No spelling errors found (347 words checked)	{"language": "es", "text_length": 4419, "total_words": 347, "max_text_length": 10000, "spelling_errors": []}	0	77	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	111
953	\N	spell_check	ok	100	No spelling errors found (290 words checked)	{"language": "es", "text_length": 3157, "total_words": 290, "max_text_length": 10000, "spelling_errors": []}	0	103	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	113
954	\N	spell_check	ok	100	No spelling errors found (752 words checked)	{"language": "es", "text_length": 10000, "total_words": 752, "max_text_length": 10000, "spelling_errors": []}	0	283	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	32
955	\N	spell_check	ok	100	No spelling errors found (437 words checked)	{"language": "es", "text_length": 5462, "total_words": 437, "max_text_length": 10000, "spelling_errors": []}	0	139	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	115
956	\N	spell_check	ok	100	No spelling errors found (709 words checked)	{"language": "es", "text_length": 10000, "total_words": 709, "max_text_length": 10000, "spelling_errors": []}	0	135	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	117
957	\N	spell_check	ok	100	No spelling errors found (538 words checked)	{"language": "es", "text_length": 6402, "total_words": 538, "max_text_length": 10000, "spelling_errors": []}	0	158	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	116
958	\N	spell_check	ok	100	No spelling errors found (57 words checked)	{"language": "es", "text_length": 660, "total_words": 57, "max_text_length": 10000, "spelling_errors": []}	0	42	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	119
959	\N	spell_check	ok	100	No spelling errors found (784 words checked)	{"language": "es", "text_length": 10000, "total_words": 784, "max_text_length": 10000, "spelling_errors": []}	0	130	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	9
960	\N	spell_check	ok	100	No spelling errors found (704 words checked)	{"language": "es", "text_length": 10000, "total_words": 704, "max_text_length": 10000, "spelling_errors": []}	0	151	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	118
961	\N	spell_check	ok	100	No spelling errors found (719 words checked)	{"language": "es", "text_length": 10000, "total_words": 719, "max_text_length": 10000, "spelling_errors": []}	0	163	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	120
962	\N	spell_check	ok	100	No spelling errors found (781 words checked)	{"language": "es", "text_length": 10000, "total_words": 781, "max_text_length": 10000, "spelling_errors": []}	0	213	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	8
963	\N	spell_check	ok	100	No spelling errors found (682 words checked)	{"language": "es", "text_length": 8244, "total_words": 682, "max_text_length": 10000, "spelling_errors": []}	0	161	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	297
964	\N	spell_check	ok	100	No spelling errors found (542 words checked)	{"language": "es", "text_length": 6781, "total_words": 542, "max_text_length": 10000, "spelling_errors": []}	0	106	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	293
965	\N	spell_check	ok	100	No spelling errors found (811 words checked)	{"language": "es", "text_length": 10000, "total_words": 811, "max_text_length": 10000, "spelling_errors": []}	0	227	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	141
966	\N	spell_check	ok	100	No spelling errors found (764 words checked)	{"language": "es", "text_length": 10000, "total_words": 764, "max_text_length": 10000, "spelling_errors": []}	0	233	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	142
967	\N	spell_check	ok	100	No spelling errors found (388 words checked)	{"language": "es", "text_length": 4815, "total_words": 388, "max_text_length": 10000, "spelling_errors": []}	0	124	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	145
968	\N	spell_check	ok	100	No spelling errors found (780 words checked)	{"language": "es", "text_length": 10000, "total_words": 780, "max_text_length": 10000, "spelling_errors": []}	0	185	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	144
969	\N	spell_check	ok	100	No spelling errors found (521 words checked)	{"language": "es", "text_length": 6556, "total_words": 521, "max_text_length": 10000, "spelling_errors": []}	0	164	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	146
970	\N	spell_check	ok	100	No spelling errors found (520 words checked)	{"language": "es", "text_length": 6538, "total_words": 520, "max_text_length": 10000, "spelling_errors": []}	0	86	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	147
971	\N	spell_check	ok	100	No spelling errors found (636 words checked)	{"language": "es", "text_length": 10000, "total_words": 636, "max_text_length": 10000, "spelling_errors": []}	0	326	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	143
973	\N	spell_check	ok	100	No spelling errors found (402 words checked)	{"language": "es", "text_length": 4848, "total_words": 402, "max_text_length": 10000, "spelling_errors": []}	0	135	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	148
974	\N	spell_check	ok	100	No spelling errors found (450 words checked)	{"language": "es", "text_length": 5505, "total_words": 450, "max_text_length": 10000, "spelling_errors": []}	0	148	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	149
975	\N	spell_check	ok	100	No spelling errors found (552 words checked)	{"language": "es", "text_length": 6926, "total_words": 552, "max_text_length": 10000, "spelling_errors": []}	0	273	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	151
976	\N	spell_check	ok	100	No spelling errors found (423 words checked)	{"language": "es", "text_length": 5134, "total_words": 423, "max_text_length": 10000, "spelling_errors": []}	0	144	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	153
977	\N	spell_check	ok	100	No spelling errors found (414 words checked)	{"language": "es", "text_length": 5060, "total_words": 414, "max_text_length": 10000, "spelling_errors": []}	0	141	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	152
978	\N	spell_check	ok	100	No spelling errors found (758 words checked)	{"language": "es", "text_length": 10000, "total_words": 758, "max_text_length": 10000, "spelling_errors": []}	0	164	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	154
979	\N	spell_check	ok	100	No spelling errors found (461 words checked)	{"language": "es", "text_length": 5441, "total_words": 461, "max_text_length": 10000, "spelling_errors": []}	0	138	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	156
980	\N	spell_check	ok	100	No spelling errors found (404 words checked)	{"language": "es", "text_length": 5068, "total_words": 404, "max_text_length": 10000, "spelling_errors": []}	0	80	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	157
981	\N	spell_check	ok	100	No spelling errors found (365 words checked)	{"language": "es", "text_length": 4297, "total_words": 365, "max_text_length": 10000, "spelling_errors": []}	0	141	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	158
982	\N	spell_check	ok	100	No spelling errors found (523 words checked)	{"language": "es", "text_length": 6319, "total_words": 523, "max_text_length": 10000, "spelling_errors": []}	0	148	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	155
983	\N	spell_check	ok	100	No spelling errors found (456 words checked)	{"language": "es", "text_length": 5777, "total_words": 456, "max_text_length": 10000, "spelling_errors": []}	0	139	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	159
984	\N	spell_check	ok	100	No spelling errors found (385 words checked)	{"language": "es", "text_length": 4544, "total_words": 385, "max_text_length": 10000, "spelling_errors": []}	0	133	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	160
985	\N	spell_check	ok	100	No spelling errors found (567 words checked)	{"language": "es", "text_length": 6808, "total_words": 567, "max_text_length": 10000, "spelling_errors": []}	0	87	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	214
986	\N	spell_check	ok	100	No spelling errors found (521 words checked)	{"language": "es", "text_length": 6303, "total_words": 521, "max_text_length": 10000, "spelling_errors": []}	0	98	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	292
987	\N	spell_check	ok	100	No spelling errors found (539 words checked)	{"language": "es", "text_length": 6484, "total_words": 539, "max_text_length": 10000, "spelling_errors": []}	0	87	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	285
988	\N	spell_check	ok	100	No spelling errors found (250 words checked)	{"language": "es", "text_length": 3190, "total_words": 250, "max_text_length": 10000, "spelling_errors": []}	0	120	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	284
989	\N	spell_check	ok	100	No spelling errors found (768 words checked)	{"language": "es", "text_length": 10000, "total_words": 768, "max_text_length": 10000, "spelling_errors": []}	0	204	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	259
990	\N	spell_check	ok	100	No spelling errors found (445 words checked)	{"language": "es", "text_length": 5471, "total_words": 445, "max_text_length": 10000, "spelling_errors": []}	0	139	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	287
991	\N	spell_check	ok	100	No spelling errors found (815 words checked)	{"language": "es", "text_length": 9933, "total_words": 815, "max_text_length": 10000, "spelling_errors": []}	0	122	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	295
992	\N	spell_check	ok	100	No spelling errors found (498 words checked)	{"language": "es", "text_length": 6181, "total_words": 498, "max_text_length": 10000, "spelling_errors": []}	0	142	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	298
993	\N	spell_check	ok	100	No spelling errors found (764 words checked)	{"language": "es", "text_length": 10000, "total_words": 764, "max_text_length": 10000, "spelling_errors": []}	0	108	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	302
994	\N	spell_check	ok	100	No spelling errors found (424 words checked)	{"language": "es", "text_length": 4965, "total_words": 424, "max_text_length": 10000, "spelling_errors": []}	0	96	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	303
995	\N	spell_check	ok	100	No spelling errors found (727 words checked)	{"language": "es", "text_length": 10000, "total_words": 727, "max_text_length": 10000, "spelling_errors": []}	0	188	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	299
996	\N	spell_check	ok	100	No spelling errors found (381 words checked)	{"language": "es", "text_length": 4242, "total_words": 381, "max_text_length": 10000, "spelling_errors": []}	0	128	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	305
997	\N	spell_check	ok	100	No spelling errors found (578 words checked)	{"language": "es", "text_length": 7442, "total_words": 578, "max_text_length": 10000, "spelling_errors": []}	0	167	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	304
998	\N	spell_check	ok	100	No spelling errors found (461 words checked)	{"language": "es", "text_length": 5760, "total_words": 461, "max_text_length": 10000, "spelling_errors": []}	0	136	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	336
999	\N	spell_check	ok	100	No spelling errors found (167 words checked)	{"language": "es", "text_length": 1860, "total_words": 167, "max_text_length": 10000, "spelling_errors": []}	0	50	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	341
1000	\N	spell_check	ok	100	No spelling errors found (455 words checked)	{"language": "es", "text_length": 5474, "total_words": 455, "max_text_length": 10000, "spelling_errors": []}	0	119	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	483
1001	\N	spell_check	ok	100	No spelling errors found (755 words checked)	{"language": "es", "text_length": 9622, "total_words": 755, "max_text_length": 10000, "spelling_errors": []}	0	190	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	340
1002	\N	spell_check	ok	100	No spelling errors found (279 words checked)	{"language": "es", "text_length": 3517, "total_words": 279, "max_text_length": 10000, "spelling_errors": []}	0	98	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	485
1003	\N	spell_check	ok	100	No spelling errors found (262 words checked)	{"language": "es", "text_length": 3250, "total_words": 262, "max_text_length": 10000, "spelling_errors": []}	0	121	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	484
1004	\N	spell_check	ok	100	No spelling errors found (307 words checked)	{"language": "es", "text_length": 3334, "total_words": 307, "max_text_length": 10000, "spelling_errors": []}	0	71	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	490
1005	\N	spell_check	ok	100	No spelling errors found (260 words checked)	{"language": "es", "text_length": 3655, "total_words": 260, "max_text_length": 10000, "spelling_errors": []}	0	104	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	486
1006	\N	spell_check	ok	100	No spelling errors found (146 words checked)	{"language": "es", "text_length": 2219, "total_words": 146, "max_text_length": 10000, "spelling_errors": []}	0	76	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	487
1007	\N	spell_check	ok	100	No spelling errors found (369 words checked)	{"language": "es", "text_length": 4047, "total_words": 369, "max_text_length": 10000, "spelling_errors": []}	0	218	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	489
1008	\N	spell_check	ok	100	No spelling errors found (356 words checked)	{"language": "es", "text_length": 4256, "total_words": 356, "max_text_length": 10000, "spelling_errors": []}	0	122	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	491
1009	\N	spell_check	ok	100	No spelling errors found (371 words checked)	{"language": "es", "text_length": 4253, "total_words": 371, "max_text_length": 10000, "spelling_errors": []}	0	145	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	492
1010	\N	spell_check	ok	100	No spelling errors found (452 words checked)	{"language": "es", "text_length": 10000, "total_words": 452, "max_text_length": 10000, "spelling_errors": []}	0	152	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	494
1011	\N	spell_check	ok	100	No spelling errors found (330 words checked)	{"language": "es", "text_length": 3921, "total_words": 330, "max_text_length": 10000, "spelling_errors": []}	0	130	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	497
1012	\N	spell_check	ok	100	No spelling errors found (716 words checked)	{"language": "es", "text_length": 10000, "total_words": 716, "max_text_length": 10000, "spelling_errors": []}	0	565	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	493
1013	\N	spell_check	ok	100	No spelling errors found (26 words checked)	{"language": "es", "text_length": 274, "total_words": 26, "max_text_length": 10000, "spelling_errors": []}	0	18	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	500
1014	\N	spell_check	ok	100	No spelling errors found (366 words checked)	{"language": "es", "text_length": 4460, "total_words": 366, "max_text_length": 10000, "spelling_errors": []}	0	82	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	499
1015	\N	spell_check	ok	100	No spelling errors found (236 words checked)	{"language": "es", "text_length": 2742, "total_words": 236, "max_text_length": 10000, "spelling_errors": []}	0	54	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	505
1016	\N	spell_check	ok	100	No spelling errors found (324 words checked)	{"language": "es", "text_length": 3822, "total_words": 324, "max_text_length": 10000, "spelling_errors": []}	0	127	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	535
1017	\N	spell_check	ok	100	No spelling errors found (277 words checked)	{"language": "es", "text_length": 3357, "total_words": 277, "max_text_length": 10000, "spelling_errors": []}	0	107	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	536
1018	\N	spell_check	ok	100	No spelling errors found (497 words checked)	{"language": "es", "text_length": 6117, "total_words": 497, "max_text_length": 10000, "spelling_errors": []}	0	113	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	172
1019	\N	spell_check	ok	100	No spelling errors found (708 words checked)	{"language": "es", "text_length": 10000, "total_words": 708, "max_text_length": 10000, "spelling_errors": []}	0	209	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	541
1020	\N	spell_check	ok	100	No spelling errors found (800 words checked)	{"language": "es", "text_length": 10000, "total_words": 800, "max_text_length": 10000, "spelling_errors": []}	0	188	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	337
1021	\N	spell_check	ok	100	No spelling errors found (509 words checked)	{"language": "es", "text_length": 5873, "total_words": 509, "max_text_length": 10000, "spelling_errors": []}	0	153	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	296
1022	\N	spell_check	ok	100	No spelling errors found (709 words checked)	{"language": "es", "text_length": 10000, "total_words": 709, "max_text_length": 10000, "spelling_errors": []}	0	162	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	542
1023	\N	spell_check	ok	100	No spelling errors found (536 words checked)	{"language": "es", "text_length": 6620, "total_words": 536, "max_text_length": 10000, "spelling_errors": []}	0	188	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	283
1024	\N	spell_check	ok	100	No spelling errors found (300 words checked)	{"language": "es", "text_length": 3388, "total_words": 300, "max_text_length": 10000, "spelling_errors": []}	0	120	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	476
1025	\N	spell_check	ok	100	No spelling errors found (407 words checked)	{"language": "es", "text_length": 4872, "total_words": 407, "max_text_length": 10000, "spelling_errors": []}	0	201	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	602
1026	\N	spell_check	ok	100	No spelling errors found (366 words checked)	{"language": "es", "text_length": 4169, "total_words": 366, "max_text_length": 10000, "spelling_errors": []}	0	145	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	561
1027	\N	spell_check	ok	100	No spelling errors found (669 words checked)	{"language": "es", "text_length": 8025, "total_words": 669, "max_text_length": 10000, "spelling_errors": []}	0	168	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	779
1028	\N	spell_check	ok	100	No spelling errors found (335 words checked)	{"language": "es", "text_length": 3825, "total_words": 335, "max_text_length": 10000, "spelling_errors": []}	0	62	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	581
1029	\N	spell_check	ok	100	No spelling errors found (477 words checked)	{"language": "es", "text_length": 5609, "total_words": 477, "max_text_length": 10000, "spelling_errors": []}	0	101	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	604
1030	\N	spell_check	ok	100	No spelling errors found (140 words checked)	{"language": "es", "text_length": 1604, "total_words": 140, "max_text_length": 10000, "spelling_errors": []}	0	94	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	671
1031	\N	spell_check	ok	100	No spelling errors found (512 words checked)	{"language": "es", "text_length": 6161, "total_words": 512, "max_text_length": 10000, "spelling_errors": []}	0	145	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	601
1032	\N	spell_check	ok	100	No spelling errors found (777 words checked)	{"language": "es", "text_length": 9604, "total_words": 777, "max_text_length": 10000, "spelling_errors": []}	0	168	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	580
1033	\N	spell_check	ok	100	No spelling errors found (512 words checked)	{"language": "es", "text_length": 6451, "total_words": 512, "max_text_length": 10000, "spelling_errors": []}	0	153	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	579
1034	\N	spell_check	ok	100	No spelling errors found (531 words checked)	{"language": "es", "text_length": 6956, "total_words": 531, "max_text_length": 10000, "spelling_errors": []}	0	167	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	778
1035	\N	spell_check	ok	100	No spelling errors found (551 words checked)	{"language": "es", "text_length": 6843, "total_words": 551, "max_text_length": 10000, "spelling_errors": []}	0	98	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	578
1036	\N	spell_check	ok	100	No spelling errors found (596 words checked)	{"language": "es", "text_length": 8011, "total_words": 596, "max_text_length": 10000, "spelling_errors": []}	0	174	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	780
1037	\N	spell_check	ok	100	No spelling errors found (379 words checked)	{"language": "es", "text_length": 4648, "total_words": 379, "max_text_length": 10000, "spelling_errors": []}	0	50	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	1188
1038	\N	spell_check	ok	100	No spelling errors found (395 words checked)	{"language": "es", "text_length": 4876, "total_words": 395, "max_text_length": 10000, "spelling_errors": []}	0	69	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	1034
1039	\N	spell_check	ok	100	No spelling errors found (230 words checked)	{"language": "es", "text_length": 2459, "total_words": 230, "max_text_length": 10000, "spelling_errors": []}	0	51	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	1174
1040	\N	spell_check	ok	100	No spelling errors found (643 words checked)	{"language": "es", "text_length": 6640, "total_words": 643, "max_text_length": 10000, "spelling_errors": []}	0	220	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	562
1041	\N	spell_check	ok	100	No spelling errors found (383 words checked)	{"language": "es", "text_length": 4761, "total_words": 383, "max_text_length": 10000, "spelling_errors": []}	0	88	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	1035
1042	\N	spell_check	ok	100	No spelling errors found (551 words checked)	{"language": "es", "text_length": 7055, "total_words": 551, "max_text_length": 10000, "spelling_errors": []}	0	213	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	1191
1043	\N	spell_check	ok	100	No spelling errors found (401 words checked)	{"language": "es", "text_length": 4834, "total_words": 401, "max_text_length": 10000, "spelling_errors": []}	0	62	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	1261
1044	\N	spell_check	ok	100	No spelling errors found (346 words checked)	{"language": "es", "text_length": 4646, "total_words": 346, "max_text_length": 10000, "spelling_errors": []}	0	58	2025-11-05 19:41:36.498963	2025-11-05 19:41:36.498963	4225
\.


--
-- Data for Name: sections; Type: TABLE DATA; Schema: public; Owner: jesusramos
--

COPY public.sections (id, name, url, active, created_at) FROM stdin;
9	Articulos Y Analisis	https://www.r4.com/articulos-y-analisis	t	2025-10-28 14:37:22
10	Renta Fija	https://www.r4.com/renta-fija	t	2025-10-28 14:37:22
11	Normativa - Politica Privacidad	https://www.r4.com/normativa/politica-privacidad	t	2025-10-28 14:37:22
14	Soluciones Easy - Carteras Easy	https://www.r4.com/soluciones-easy/carteras-easy	t	2025-10-28 14:37:22
15	Tarifas	https://www.r4.com/tarifas	t	2025-10-28 14:37:22
17	Soluciones Easy - Plan Easy	https://www.r4.com/soluciones-easy/plan-easy	t	2025-10-28 14:37:22
18	Politica Privacidad - Politica Privacidad Clientes	https://www.r4.com/normativa/politica-privacidad/politica-privacidad-clientes	t	2025-10-28 14:37:22
19	Contacto	https://www.r4.com/contacto	t	2025-10-28 14:37:22
21	Soluciones Easy	https://www.r4.com/soluciones-easy	t	2025-10-28 14:37:22
22	Articulos Y Analisis - Mercados	https://www.r4.com/articulos-y-analisis/mercados	t	2025-10-28 14:37:22
23	Normativa - Tablon De Anuncios	https://www.r4.com/normativa/tablon-de-anuncios	t	2025-10-28 14:37:22
24	Articulos Y Analisis - Tecnico	https://www.r4.com/articulos-y-analisis/tecnico	t	2025-10-28 14:37:22
27	Fondos De Inversion	https://www.r4.com/fondos-de-inversion	t	2025-10-28 14:37:22
30	Que Necesitas - Red Oficinas	https://www.r4.com/que-necesitas/red-oficinas	t	2025-10-28 14:37:22
31	Articulos Y Analisis - Ideas	https://www.r4.com/articulos-y-analisis/ideas	t	2025-10-28 14:37:22
33	Normativa - Politica Cookies	https://www.r4.com/normativa/politica-cookies	t	2025-10-28 14:37:22
35	Etfs - Que Son Etfs	https://www.r4.com/broker-online/productos-de-inversion/etfs/que-son-etfs	t	2025-10-28 14:37:22
37	Normativa	https://www.r4.com/normativa	t	2025-10-28 14:37:22
38	Cfds - Que Son Cfds	https://www.r4.com/broker-online/productos-de-inversion/cfds/que-son-cfds	t	2025-10-28 14:37:22
39	Asesoramiento	https://www.r4.com/asesoramiento	t	2025-10-28 14:37:22
40	Normativa - Aviso Legal	https://www.r4.com/normativa/aviso-legal	t	2025-10-28 14:37:22
41	Broker Online - Productos De Inversion	https://www.r4.com/broker-online/productos-de-inversion	t	2025-10-28 14:37:22
49	Hazte Cliente	https://www.r4.com/hazte-cliente	t	2025-10-28 14:37:22
53	Renta Fija - Letras Del Tesoro	https://www.r4.com/renta-fija/letras-del-tesoro	t	2025-10-28 14:37:22
54	Renta Fija - Invertir Bonos Renta Fija	https://www.r4.com/renta-fija/invertir-bonos-renta-fija	t	2025-10-28 14:37:22
58	Politica Privacidad - Politica Privacidad Noclientes	https://www.r4.com/normativa/politica-privacidad/politica-privacidad-noclientes	t	2025-10-28 14:37:22
59	Broker Online - Herramientas	https://www.r4.com/broker-online/herramientas	t	2025-10-28 14:37:22
60	Articulos Y Analisis - Fondos	https://www.r4.com/articulos-y-analisis/fondos	t	2025-10-28 14:37:22
61	Normativa - Codigo Lei	https://www.r4.com/normativa/codigo-lei	t	2025-10-28 14:37:22
62	Seguros	https://www.r4.com/seguros	t	2025-10-28 14:37:22
63	Columnas De Autores - Vive La Pasion De Los Mercados	https://www.r4.com/columnas-de-autores/vive-la-pasion-de-los-mercados	t	2025-10-28 14:37:22
64	Formacion - Empezar Invertir	https://www.r4.com/que-necesitas/formacion/empezar-invertir	t	2025-10-28 14:37:22
65	Opciones - Que Son Opciones	https://www.r4.com/broker-online/productos-de-inversion/opciones/que-son-opciones	t	2025-10-28 14:37:22
67	Soluciones Easy - Fondos Perfilados	https://www.r4.com/soluciones-easy/fondos-perfilados	t	2025-10-28 14:37:22
68	Empezar Invertir - Como Invertir Mi Dinero	https://www.r4.com/que-necesitas/formacion/empezar-invertir/como-invertir-mi-dinero	t	2025-10-28 14:37:22
70	Fondos De Inversion - Fiscalidad Tributacion Fondos De Inversion	https://www.r4.com/fondos-de-inversion/fiscalidad-tributacion-fondos-de-inversion	t	2025-10-28 14:37:22
71	Fondos De Inversion - Comisiones Fondos De Inversion	https://www.r4.com/fondos-de-inversion/comisiones-fondos-de-inversion	t	2025-10-28 14:37:22
72	Warrants - Que Son Warrants	https://www.r4.com/broker-online/productos-de-inversion/warrants/que-son-warrants	t	2025-10-28 14:37:22
73	Formacion - Diccionario	https://www.r4.com/que-necesitas/formacion/diccionario	t	2025-10-28 14:37:22
74	Articulos Y Analisis - Cripto	https://www.r4.com/articulos-y-analisis/cripto	t	2025-10-28 14:37:22
76	Que Necesitas - Servicios Bancarios	https://www.r4.com/que-necesitas/servicios-bancarios	t	2025-10-28 14:37:22
78	Fondos De Inversion - Cuando Entrar En Un Fondo De Inversion	https://www.r4.com/fondos-de-inversion/cuando-entrar-en-un-fondo-de-inversion	t	2025-10-28 14:37:22
79	Que Necesitas - App Renta4	https://www.r4.com/que-necesitas/app-renta4	t	2025-10-28 14:37:22
81	Empezar Invertir - Como Rentabilizar Mis Ahorros	https://www.r4.com/que-necesitas/formacion/empezar-invertir/como-rentabilizar-mis-ahorros	t	2025-10-28 14:37:22
82	Fondos De Inversion - Como Funciona Un Fondo De Inversion	https://www.r4.com/fondos-de-inversion/como-funciona-un-fondo-de-inversion	t	2025-10-28 14:37:22
83	Que Necesitas - Tarjetas De Pago	https://www.r4.com/que-necesitas/tarjetas-de-pago	t	2025-10-28 14:37:22
85	Cuanto Dinero Necesito Para Invertir - Invertir 10000 Euros	https://www.r4.com/que-necesitas/formacion/empezar-invertir/cuanto-dinero-necesito-para-invertir/invertir-10000-euros	t	2025-10-28 14:37:22
86	Que Necesitas - Formacion	https://www.r4.com/que-necesitas/formacion	t	2025-10-28 14:37:22
87	Soluciones Easy - Asesoramiento Easy	https://www.r4.com/soluciones-easy/asesoramiento-easy	t	2025-10-28 14:37:22
88	Quienes Somos	https://www.r4.com/quienes-somos	t	2025-10-28 14:37:22
89	Fondos De Inversion - Plataforma Fondotop	https://www.r4.com/fondos-de-inversion/plataforma-fondotop	t	2025-10-28 14:37:22
90	Planes De Pensiones - Aportacion Maxima Planes De Pensiones	https://www.r4.com/planes-de-pensiones/aportacion-maxima-planes-de-pensiones	t	2025-10-28 14:37:22
91	Bolsa - Que Es La Bolsa	https://www.r4.com/broker-online/productos-de-inversion/bolsa/que-es-la-bolsa	t	2025-10-28 14:37:22
92	Letras Del Tesoro - Que Son Las Letras Del Tesoro	https://www.r4.com/renta-fija/letras-del-tesoro/que-son-las-letras-del-tesoro	t	2025-10-28 14:37:22
93	Servicios - Ahorro Periodico	https://www.r4.com/fondos-de-inversion/servicios/ahorro-periodico	t	2025-10-28 14:37:22
94	Productos De Inversion - Opciones	https://www.r4.com/broker-online/productos-de-inversion/opciones	t	2025-10-28 14:37:22
95	Academiar4 - Otros Productos Inversion	https://www.r4.com/academiar4/otros-productos-inversion	t	2025-10-28 14:37:22
96	Fondos De Inversion - Rentabilidad Fondos De Inversion	https://www.r4.com/fondos-de-inversion/rentabilidad-fondos-de-inversion	t	2025-10-28 14:37:22
97	Productos De Inversion - Futuros	https://www.r4.com/broker-online/productos-de-inversion/futuros	t	2025-10-28 14:37:22
98	Fondos De Inversion - Riesgos De Los Fondos De Inversion	https://www.r4.com/fondos-de-inversion/riesgos-de-los-fondos-de-inversion	t	2025-10-28 14:37:22
99	Futuros - Que Son Futuros	https://www.r4.com/broker-online/productos-de-inversion/futuros/que-son-futuros	t	2025-10-28 14:37:22
101	Formacion - Ahorrador A Inversor	https://www.r4.com/que-necesitas/formacion/ahorrador-a-inversor	t	2025-10-28 14:37:22
103	Formacion - Conferencias Seminarios	https://www.r4.com/que-necesitas/formacion/conferencias-seminarios	t	2025-10-28 14:37:22
104	Normativa - Normativa Mifid	https://www.r4.com/normativa/normativa-mifid	t	2025-10-28 14:37:22
105	Servicios - Multidivisa	https://www.r4.com/fondos-de-inversion/servicios/multidivisa	t	2025-10-28 14:37:22
106	Empezar Invertir - Beneficios Inversion Largo Plazo	https://www.r4.com/que-necesitas/formacion/empezar-invertir/beneficios-inversion-largo-plazo	t	2025-10-28 14:37:22
107	Articulos Y Analisis - Area Prensa	https://www.r4.com/articulos-y-analisis/area-prensa	t	2025-10-28 14:37:22
108	Fondos De Inversion - Traspaso De Fondos De Inversion	https://www.r4.com/fondos-de-inversion/traspaso-de-fondos-de-inversion	t	2025-10-28 14:37:22
109	Bolsa - Traspaso Carteras Valores	https://www.r4.com/broker-online/productos-de-inversion/bolsa/traspaso-carteras-valores	t	2025-10-28 14:37:22
110	Normativa - Canal Denuncias	https://www.r4.com/normativa/canal-denuncias	t	2025-10-28 14:37:22
111	Fondos De Inversion - Donde Contratar Fondos De Inversion	https://www.r4.com/fondos-de-inversion/donde-contratar-fondos-de-inversion	t	2025-10-28 14:37:22
112	Formacion - Guias Inversor	https://www.r4.com/que-necesitas/formacion/guias-inversor	t	2025-10-28 14:37:22
113	Formacion - Boletines	https://www.r4.com/que-necesitas/formacion/boletines	t	2025-10-28 14:37:22
114	Politica Privacidad - Politica Privacidad App	https://www.r4.com/normativa/politica-privacidad/politica-privacidad-app	t	2025-10-28 14:37:22
115	Servicios Bancarios - Bizum	https://www.r4.com/que-necesitas/servicios-bancarios/bizum	t	2025-10-28 14:37:22
116	Productos De Inversion - Forex	https://www.r4.com/broker-online/productos-de-inversion/forex	t	2025-10-28 14:37:22
117	Fondos De Inversion - Los Mejores Fondos De Inversion Como Identificarlos	https://www.r4.com/fondos-de-inversion/los-mejores-fondos-de-inversion-como-identificarlos	t	2025-10-28 14:37:22
118	Formacion - Webinars	https://www.r4.com/que-necesitas/formacion/webinars	t	2025-10-28 14:37:22
119	Soluciones Digitales - Asesor Digital Inteligente Fondos	https://www.r4.com/que-necesitas/soluciones-digitales/asesor-digital-inteligente-fondos	t	2025-10-28 14:37:22
120	Normativa - Guia Seguridad	https://www.r4.com/normativa/guia-seguridad	t	2025-10-28 14:37:22
121	Formacion - Tutoriales	https://www.r4.com/que-necesitas/formacion/tutoriales	t	2025-10-28 14:37:22
122	Categorias - Planes De Pensiones Renta Variable	https://www.r4.com/planes-de-pensiones/categorias/planes-de-pensiones-renta-variable	t	2025-10-28 14:37:22
123	Categorias - Planes De Pensiones Renta Fija	https://www.r4.com/planes-de-pensiones/categorias/planes-de-pensiones-renta-fija	t	2025-10-28 14:37:22
124	Que Necesitas - Compromiso Social	https://www.r4.com/que-necesitas/compromiso-social	t	2025-10-28 14:37:22
125	Fondos De Inversion - Que Es Un Fondo De Inversion	https://www.r4.com/fondos-de-inversion/que-es-un-fondo-de-inversion	t	2025-10-28 14:37:22
126	Planes De Pensiones - Mejores Planes De Pensiones	https://www.r4.com/planes-de-pensiones/mejores-planes-de-pensiones	t	2025-10-28 14:37:22
127	Bolsa - Empezar A Operar En Bolsa	https://www.r4.com/broker-online/productos-de-inversion/bolsa/empezar-a-operar-en-bolsa	t	2025-10-28 14:37:22
160	Serviciosr4	https://www.r4.com/serviciosr4/acciones-internacionales	t	2025-10-28 14:37:22
129	Plataforma Fondotop - Gestoras Internacionales	https://www.r4.com/fondos-de-inversion/plataforma-fondotop/gestoras-internacionales	t	2025-10-28 14:37:22
130	Categorias - Planes De Pensiones Mixtos	https://www.r4.com/planes-de-pensiones/categorias/planes-de-pensiones-mixtos	t	2025-10-28 14:37:22
131	Planes De Pensiones - Traspaso Planes De Pensiones	https://www.r4.com/planes-de-pensiones/traspaso-planes-de-pensiones	t	2025-10-28 14:37:22
132	Forex - Futuros Xrolling	https://www.r4.com/broker-online/productos-de-inversion/forex/futuros-xrolling	t	2025-10-28 14:37:22
133	Fondos De Inversion - Cursos Fondo De Inversion	https://www.r4.com/fondos-de-inversion/cursos-fondo-de-inversion	t	2025-10-28 14:37:22
134	Planes De Pensiones - Fiscalidad Planes De Pensiones	https://www.r4.com/planes-de-pensiones/fiscalidad-planes-de-pensiones	t	2025-10-28 14:37:22
166	Soluciones Easy - Ursos Finanzas Gratis	https://www.r4.com/serviciosr4/cursos-finanzas-gratis	t	2025-10-28 14:37:22
137	Planes De Pensiones - Que Es Una Epsv	https://www.r4.com/planes-de-pensiones/que-es-una-epsv	t	2025-10-28 14:37:22
138	Planes De Pensiones - Rentabilidad Planes De Pensiones	https://www.r4.com/planes-de-pensiones/rentabilidad-planes-de-pensiones	t	2025-10-28 14:37:22
139	Planes De Pensiones - Comisiones Planes De Pensiones	https://www.r4.com/planes-de-pensiones/comisiones-planes-de-pensiones	t	2025-10-28 14:37:22
140	Formacion - Slow Finance	https://www.r4.com/que-necesitas/formacion/slow-finance	t	2025-10-28 14:37:22
147	Servicios Gestion - Planificacion Financiera	https://www.r4.com/servicios-gestion/planificacion-financiera	t	2025-10-28 14:37:22
148	Planes De Pensiones - Como Elegir Un Plan De Pensiones	https://www.r4.com/planes-de-pensiones/como-elegir-un-plan-de-pensiones	t	2025-10-28 14:37:22
150	Planes De Pensiones - Como Funciona Un Plan De Pensiones	https://www.r4.com/planes-de-pensiones/como-funciona-un-plan-de-pensiones	t	2025-10-28 14:37:22
151	Diccionario - Que Es Un Dividendo	https://www.r4.com/que-necesitas/formacion/diccionario/que-es-un-dividendo	t	2025-10-28 14:37:22
152	Servicios Gestion	https://www.r4.com/servicios-gestion	t	2025-10-28 14:37:22
153	Fondos De Inversion - Tipos De Fondos De Inversion	https://www.r4.com/fondos-de-inversion/tipos-de-fondos-de-inversion	t	2025-10-28 14:37:22
155	Formacion - Conferencias Multigestora	https://www.r4.com/que-necesitas/formacion/conferencias-multigestora	t	2025-10-28 14:37:22
156	Planes De Pensiones - Rescate Planes De Pensiones	https://www.r4.com/planes-de-pensiones/rescate-planes-de-pensiones	t	2025-10-28 14:37:22
170	Diccionario - Que Es Un Broker	https://www.r4.com/que-necesitas/formacion/diccionario/que-es-un-broker	t	2025-10-28 14:37:22
171	Planes De Pensiones - Que Es Un Plan De Pensiones	https://www.r4.com/planes-de-pensiones/que-es-un-plan-de-pensiones	t	2025-10-28 14:37:22
172	Diccionario - Que Es Una Accion	https://www.r4.com/que-necesitas/formacion/diccionario/que-es-una-accion	t	2025-10-28 14:37:22
149	Planes De Pensiones - Tipos Planes De Pensiones	https://www.r4.com/planes-de-pensiones/tipos-planes-de-pensiones	t	2025-10-28 14:37:22
146	Quieres Mas - Nversion Para Todos	https://www.r4.com/que-necesitas/quieres-mas/inversion-para-todos	t	2025-10-28 14:37:22
145	Quieres Mas - Specialista Todos [NO EXISTE]	https://www.r4.com/que-necesitas/quieres-mas/especialista-todos	f	2025-10-28 14:37:22
144	Quieres Mas - Entable Sostenible [NO EXISTE]	https://www.r4.com/que-necesitas/quieres-mas/rentable-sostenible	f	2025-10-28 14:37:22
158	Erviciosr4 - Carteras Easy [NO EXISTE]	https://www.r4.com/serviciosr4/carteras-easy	f	2025-10-28 14:37:22
159	Erviciosr4 - S50 [NO EXISTE]	https://www.r4.com/serviciosr4/s50	f	2025-10-28 14:37:22
161	Soluciones Easy - Oletin Analisis Tecnico	https://www.r4.com/serviciosr4/boletin-analisis-tecnico	t	2025-10-28 14:37:22
162	Soluciones Easy - Oletin Warrants	https://www.r4.com/serviciosr4/boletin-warrants	t	2025-10-28 14:37:22
164	Soluciones Easy - Roker Online Compra Acciones	https://www.r4.com/serviciosr4/broker-online-para-invertir-en-bolsa-con-ventaja	t	2025-10-28 14:37:22
163	Soluciones Easy - Roker Online Las Mejores Tarifas	https://www.r4.com/serviciosr4/broker-online-con-las-mejores-tarifas	t	2025-10-28 14:37:22
168	Soluciones Easy - Escarga Gratis Guia Que Son Etfs	https://www.r4.com/serviciosr4/descarga-gratis-guia-que-son-etfs	t	2025-10-28 14:37:22
157	Erviciosr4 [DUPLICADO-TYPO]	https://www.r4.com/erviciosr4	f	2025-10-28 14:37:22
3	Conferencias [OBSOLETA]	https://www.r4.com/conferencias	f	2025-10-28 14:37:22
4	Clientes [OBSOLETA]	https://www.r4.com/clientes	f	2025-10-28 14:37:22
6	Normativa - Dnie [OBSOLETA]	https://www.r4.com/normativa/dnie	f	2025-10-28 14:37:22
12	Errores - Error 404 [OBSOLETA]	https://www.r4.com/errores/error-404	f	2025-10-28 14:37:22
51	Columnas De Autores - El Blog De Jsq [OBSOLETA]	https://www.r4.com/columnas-de-autores/el-blog-de-jsq	f	2025-10-28 14:37:22
135	Inversiones Alternativas [OBSOLETA]	https://www.r4.com/inversiones-alternativas	f	2025-10-28 14:37:22
141	Que Necesitas - Quieres Mas [OBSOLETA]	https://www.r4.com/que-necesitas/quieres-mas	f	2025-10-28 14:37:22
142	Quieres Mas - Mas Digital [OBSOLETA]	https://www.r4.com/que-necesitas/quieres-mas/mas-digital	f	2025-10-28 14:37:22
143	Quieres Mas - Cercano Digital [OBSOLETA]	https://www.r4.com/que-necesitas/quieres-mas/cercano-digital	f	2025-10-28 14:37:22
165	Soluciones Easy - Broker Online Para Invertir Cob Ventaja [OBSOLETA]	https://www.r4.com/soluciones-easy/broker-online-para-invertir-cob-ventaja	f	2025-10-28 14:37:22
167	Soluciones Easy - Cbermonday [OBSOLETA]	https://www.r4.com/soluciones-easy/cbermonday	f	2025-10-28 14:37:22
169	Soluciones Easy - ... [OBSOLETA]	https://www.r4.com/soluciones-easy/...	f	2025-10-28 14:37:22
173	Que Necesitas - Soluciones Digitales [OBSOLETA]	https://www.r4.com/que-necesitas/soluciones-digitales	f	2025-10-28 14:37:22
1	Planes De Pensiones - Categorias [NO EXISTE]	https://www.r4.com/planes-de-pensiones/categorias	f	2025-10-28 14:37:22
25	Categorias - Fondos De Inversion Renta Fija [NO EXISTE]	https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-renta-fija	f	2025-10-28 14:37:22
29	Categorias - Fondos De Inversion Renta Variable [NO EXISTE]	https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-renta-variable	f	2025-10-28 14:37:22
43	Categorias - Fondos De Inversion Monetarios [NO EXISTE]	https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-monetarios	f	2025-10-28 14:37:22
44	Categorias - Fondos De Inversion Criptomonedas [NO EXISTE]	https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-criptomonedas	f	2025-10-28 14:37:22
55	Categorias - Fondos De Inversion Mixtos [NO EXISTE]	https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-mixtos	f	2025-10-28 14:37:22
56	Categorias - Fondos De Inversion Retorno Absoluto [NO EXISTE]	https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-retorno-absoluto	f	2025-10-28 14:37:22
66	Categorias - Fondos De Inversion Tematicos [NO EXISTE]	https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-tematicos	f	2025-10-28 14:37:22
75	Categorias - Fondos Perfilados [NO EXISTE]	https://www.r4.com/fondos-de-inversion/categorias/fondos-perfilados	f	2025-10-28 14:37:22
7	Carteras Gestionadas [NO EXISTE]	https://www.r4.com/carteras-gestionadas	f	2025-10-28 14:37:22
28	Carteras Acciones - 5 Grandes [NO EXISTE]	https://www.r4.com/carteras-gestionadas/carteras-acciones/5-grandes	f	2025-10-28 14:37:22
34	Carteras Acciones - Cardiv [NO EXISTE]	https://www.r4.com/carteras-gestionadas/carteras-acciones/cardiv	f	2025-10-28 14:37:22
42	Carteras Acciones - Versatil [NO EXISTE]	https://www.r4.com/carteras-gestionadas/carteras-acciones/versatil	f	2025-10-28 14:37:22
45	Carteras De Fondos - Conservadora [NO EXISTE]	https://www.r4.com/carteras-gestionadas/carteras-de-fondos/conservadora	f	2025-10-28 14:37:22
46	Carteras De Fondos - Tolerante [NO EXISTE]	https://www.r4.com/carteras-gestionadas/carteras-de-fondos/tolerante	f	2025-10-28 14:37:22
47	Carteras De Fondos - Rendimiento [NO EXISTE]	https://www.r4.com/carteras-gestionadas/carteras-de-fondos/rendimiento	f	2025-10-28 14:37:22
48	Carteras De Fondos - Moderada [NO EXISTE]	https://www.r4.com/carteras-gestionadas/carteras-de-fondos/moderada	f	2025-10-28 14:37:22
50	Carteras De Fondos - Dinamica [NO EXISTE]	https://www.r4.com/carteras-gestionadas/carteras-de-fondos/dinamica	f	2025-10-28 14:37:22
52	Carteras Gestionadas - Carteras Acciones [NO EXISTE]	https://www.r4.com/carteras-gestionadas/carteras-acciones	f	2025-10-28 14:37:22
2	Academiar4 - Formulario Cursos [NO EXISTE]	https://www.r4.com/academiar4/formulario-cursos	f	2025-10-28 14:37:22
5	R4 - HOME  [NO EXISTE]	https://www.r4.com/	f	2025-10-28 14:37:22
8	Fondos De Inversion - Seleccion50 [NO EXISTE]	https://www.r4.com/fondos-de-inversion/seleccion50	f	2025-10-28 14:37:22
13	Fondos Planes [NO EXISTE]	https://www.r4.com/fondos-planes	f	2025-10-28 14:37:22
16	Broker Online [NO EXISTE]	https://www.r4.com/broker-online	f	2025-10-28 14:37:22
20	Productos De Inversion - Etfs [NO EXISTE]	https://www.r4.com/broker-online/productos-de-inversion/etfs	f	2025-10-28 14:37:22
26	Productos De Inversion - Bolsa [NO EXISTE]	https://www.r4.com/broker-online/productos-de-inversion/bolsa	f	2025-10-28 14:37:22
32	Carteras Gestionadas - Carteras De Fondos [NO EXISTE]	https://www.r4.com/carteras-gestionadas/carteras-de-fondos	f	2025-10-28 14:37:22
36	Productos De Inversion - Cripto [NO EXISTE]	https://www.r4.com/broker-online/productos-de-inversion/cripto	f	2025-10-28 14:37:22
57	Planes De Pensiones [NO EXISTE]	https://www.r4.com/planes-de-pensiones	f	2025-10-28 14:37:22
69	Carteras Gestionadas - Gestion Personalizada [NO EXISTE]	https://www.r4.com/carteras-gestionadas/gestion-personalizada	f	2025-10-28 14:37:22
77	Productos De Inversion - Derivados [NO EXISTE]	https://www.r4.com/broker-online/productos-de-inversion/derivados	f	2025-10-28 14:37:22
80	Productos De Inversion - Cfds [NO EXISTE]	https://www.r4.com/broker-online/productos-de-inversion/cfds	f	2025-10-28 14:37:22
84	Productos De Inversion - Warrants [NO EXISTE]	https://www.r4.com/broker-online/productos-de-inversion/warrants	f	2025-10-28 14:37:22
100	Planes De Pensiones - Plan De Pensiones Autonomos [NO EXISTE]	https://www.r4.com/planes-de-pensiones/plan-de-pensiones-autonomos	f	2025-10-28 14:37:22
102	Bolsa - Cursos Bolsa [NO EXISTE]	https://www.r4.com/broker-online/productos-de-inversion/bolsa/cursos-bolsa	f	2025-10-28 14:37:22
128	Fondos De Inversion - Sicav [NO EXISTE]	https://www.r4.com/fondos-de-inversion/sicav	f	2025-10-28 14:37:22
136	Autor [NO EXISTE]	https://www.r4.com/autor	f	2025-10-28 14:37:22
154	Futuros - Garantias Futuros [NO EXISTE]	https://www.r4.com/broker-online/productos-de-inversion/futuros/garantias-futuros	f	2025-10-28 14:37:22
\.


--
-- Data for Name: task_types; Type: TABLE DATA; Schema: public; Owner: jesusramos
--

COPY public.task_types (id, name, display_name, periodicity, display_order) FROM stdin;
1	enlaces_rotos	Enlaces rotos	weekly	1
2	enlaces_incorrectos	Enlaces incorrectos	weekly	2
3	textos_erratas	Textos – erratas	monthly	3
4	informacion_actualizada	Información actualizada	monthly	4
5	preguntas_frecuentes	Preguntas frecuentes	quarterly	5
6	ctas	CTAs	monthly	6
7	imagenes	Imágenes	monthly	7
8	diseno	Diseño	quarterly	8
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: jesusramos
--

COPY public.tasks (id, section_id, task_type_id, period, status, observations, completed_date, completed_by, created_at) FROM stdin;
1	1	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
2	2	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
3	3	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
4	4	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
5	5	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
6	6	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
7	7	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
8	8	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
9	9	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
10	10	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
11	11	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
12	12	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
13	13	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
14	14	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
15	15	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
16	16	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
17	17	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
18	18	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
19	19	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
20	20	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
21	21	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
22	22	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
23	23	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
24	24	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
25	25	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
26	26	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
27	27	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
28	28	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
29	29	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
30	30	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
31	31	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
32	32	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
33	33	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
34	34	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
35	35	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
36	36	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
37	37	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
38	38	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
39	39	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
40	40	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
41	41	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
42	42	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
43	43	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
44	44	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
45	45	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
46	46	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
47	47	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
48	48	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
49	49	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
50	50	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
51	51	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
52	52	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
53	53	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
54	54	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
55	55	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
56	56	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
57	57	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
58	58	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
59	59	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
60	60	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
61	61	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
62	62	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
63	63	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
64	64	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
65	65	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
66	66	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
67	67	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
68	68	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
69	69	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
70	70	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
71	71	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
72	72	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
73	73	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
74	74	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
75	75	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
76	76	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
77	77	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
78	78	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
79	79	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
80	80	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
81	81	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
82	82	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
83	83	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
84	84	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
85	85	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
86	86	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
87	87	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
88	88	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
89	89	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
90	90	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
91	91	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
92	92	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
93	93	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
94	94	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
95	95	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
96	96	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
97	97	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
98	98	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
99	99	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
100	100	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
101	101	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
102	102	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
103	103	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
104	104	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
105	105	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
106	106	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
107	107	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
108	108	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
109	109	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
110	110	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
111	111	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
112	112	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
113	113	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
114	114	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
115	115	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
116	116	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
117	117	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
118	118	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
119	119	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
120	120	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
121	121	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
122	122	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
123	123	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
124	124	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
125	125	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
126	126	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
127	127	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
128	128	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
129	129	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
130	130	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
131	131	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
132	132	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
133	133	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
134	134	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
135	135	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
136	136	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
137	137	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
138	138	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
139	139	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
140	140	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
141	141	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
142	142	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
143	143	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
144	144	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
145	145	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
146	146	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
147	147	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
148	148	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
149	149	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
150	150	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
151	151	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
152	152	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
153	153	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
154	154	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
155	155	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
156	156	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
157	157	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
158	158	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
159	159	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
160	160	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
161	161	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
162	162	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
163	163	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
164	164	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
165	165	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
166	166	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
167	167	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
168	168	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
169	169	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
170	170	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
171	171	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
172	172	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
173	173	1	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
174	1	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
175	2	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
176	3	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
177	4	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
178	5	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
179	6	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
180	7	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
181	8	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
182	9	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
183	10	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
184	11	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
185	12	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
186	13	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
187	14	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
188	15	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
189	16	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
190	17	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
191	18	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
192	19	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
193	20	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
194	21	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
195	22	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
196	23	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
197	24	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
198	25	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
199	26	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
200	27	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
201	28	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
202	29	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
203	30	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
204	31	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
205	32	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
206	33	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
207	34	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
208	35	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
209	36	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
210	37	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
211	38	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
212	39	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
213	40	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
214	41	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
215	42	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
216	43	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
217	44	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
218	45	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
219	46	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
220	47	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
221	48	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
222	49	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
223	50	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
224	51	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
225	52	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
226	53	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
227	54	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
228	55	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
229	56	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
230	57	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
231	58	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
232	59	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
233	60	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
234	61	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
235	62	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
236	63	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
237	64	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
238	65	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
239	66	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
240	67	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
241	68	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
242	69	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
243	70	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
244	71	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
245	72	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
246	73	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
247	74	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
248	75	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
249	76	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
250	77	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
251	78	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
252	79	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
253	80	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
254	81	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
255	82	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
256	83	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
257	84	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
258	85	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
259	86	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
260	87	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
261	88	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
262	89	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
263	90	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
264	91	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
265	92	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
266	93	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
267	94	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
268	95	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
269	96	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
270	97	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
271	98	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
272	99	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
273	100	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
274	101	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
275	102	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
276	103	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
277	104	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
278	105	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
279	106	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
280	107	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
281	108	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
282	109	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
283	110	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
284	111	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
285	112	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
286	113	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
287	114	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
288	115	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
289	116	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
290	117	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
291	118	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
292	119	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
293	120	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
294	121	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
295	122	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
296	123	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
297	124	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
298	125	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
299	126	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
300	127	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
301	128	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
302	129	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
303	130	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
304	131	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
305	132	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
306	133	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
307	134	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
308	135	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
309	136	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
310	137	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
311	138	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
312	139	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
313	140	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
314	141	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
315	142	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
316	143	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
317	144	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
318	145	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
319	146	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
320	147	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
321	148	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
322	149	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
323	150	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
324	151	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
325	152	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
326	153	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
327	154	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
328	155	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
329	156	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
330	157	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
331	158	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
332	159	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
333	160	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
334	161	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
335	162	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
336	163	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
337	164	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
338	165	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
339	166	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
340	167	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
341	168	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
342	169	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
343	170	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
344	171	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
345	172	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
346	173	2	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
347	1	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
348	2	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
349	3	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
350	4	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
351	5	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
352	6	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
353	7	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
354	8	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
355	9	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
356	10	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
357	11	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
358	12	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
359	13	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
360	14	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
361	15	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
362	16	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
363	17	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
364	18	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
365	19	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
366	20	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
367	21	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
368	22	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
369	23	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
370	24	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
371	25	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
372	26	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
373	27	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
374	28	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
375	29	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
376	30	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
377	31	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
378	32	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
379	33	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
380	34	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
381	35	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
382	36	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
383	37	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
384	38	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
385	39	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
386	40	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
387	41	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
388	42	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
389	43	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
390	44	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
391	45	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
392	46	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
393	47	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
394	48	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
395	49	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
396	50	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
397	51	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
398	52	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
399	53	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
400	54	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
401	55	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
402	56	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
403	57	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
404	58	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
405	59	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
406	60	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
407	61	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
408	62	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
409	63	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
410	64	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
411	65	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
412	66	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
413	67	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
414	68	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
415	69	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
416	70	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
417	71	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
418	72	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
419	73	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
420	74	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
421	75	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
422	76	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
423	77	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
424	78	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
425	79	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
426	80	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
427	81	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
428	82	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
429	83	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
430	84	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
431	85	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
432	86	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
433	87	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
434	88	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
435	89	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
436	90	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
437	91	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
438	92	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
439	93	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
440	94	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
441	95	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
442	96	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
443	97	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
444	98	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
445	99	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
446	100	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
447	101	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
448	102	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
449	103	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
450	104	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
451	105	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
452	106	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
453	107	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
454	108	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
455	109	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
456	110	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
457	111	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
458	112	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
459	113	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
460	114	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
461	115	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
462	116	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
463	117	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
464	118	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
465	119	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
466	120	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
467	121	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
468	122	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
469	123	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
470	124	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
471	125	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
472	126	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
473	127	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
474	128	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
475	129	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
476	130	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
477	131	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
478	132	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
479	133	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
480	134	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
481	135	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
482	136	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
483	137	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
484	138	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
485	139	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
486	140	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
487	141	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
488	142	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
489	143	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
490	144	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
491	145	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
492	146	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
493	147	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
494	148	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
495	149	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
496	150	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
497	151	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
498	152	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
499	153	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
500	154	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
501	155	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
502	156	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
503	157	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
504	158	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
505	159	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
506	160	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
507	161	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
508	162	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
509	163	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
510	164	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
511	165	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
512	166	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
513	167	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
514	168	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
515	169	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
516	170	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
517	171	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
518	172	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
519	173	3	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
520	1	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
521	2	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
522	3	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
523	4	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
524	5	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
525	6	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
526	7	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
527	8	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
528	9	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
529	10	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
530	11	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
531	12	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
532	13	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
533	14	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
534	15	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
535	16	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
536	17	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
537	18	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
538	19	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
539	20	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
540	21	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
541	22	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
542	23	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
543	24	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
544	25	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
545	26	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
546	27	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
547	28	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
548	29	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
549	30	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
550	31	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
551	32	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
552	33	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
553	34	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
554	35	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
555	36	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
556	37	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
557	38	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
558	39	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
559	40	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
560	41	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
561	42	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
562	43	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
563	44	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
564	45	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
565	46	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
566	47	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
567	48	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
568	49	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
569	50	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
570	51	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
571	52	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
572	53	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
573	54	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
574	55	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
575	56	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
576	57	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
577	58	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
578	59	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
579	60	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
580	61	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
581	62	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
582	63	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
583	64	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
584	65	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
585	66	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
586	67	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
587	68	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
588	69	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
589	70	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
590	71	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
591	72	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
592	73	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
593	74	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
594	75	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
595	76	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
596	77	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
597	78	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
598	79	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
599	80	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
600	81	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
601	82	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
602	83	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
603	84	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
604	85	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
605	86	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
606	87	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
607	88	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
608	89	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
609	90	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
610	91	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
611	92	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
612	93	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
613	94	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
614	95	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
615	96	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
616	97	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
617	98	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
618	99	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
619	100	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
620	101	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
621	102	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
622	103	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
623	104	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
624	105	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
625	106	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
626	107	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
627	108	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
628	109	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
629	110	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
630	111	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
631	112	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
632	113	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
633	114	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
634	115	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
635	116	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
636	117	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
637	118	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
638	119	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
639	120	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
640	121	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
641	122	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
642	123	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
643	124	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
644	125	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
645	126	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
646	127	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
647	128	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
648	129	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
649	130	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
650	131	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
651	132	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
652	133	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
653	134	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
654	135	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
655	136	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
656	137	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
657	138	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
658	139	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
659	140	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
660	141	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
661	142	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
662	143	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
663	144	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
664	145	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
665	146	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
666	147	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
667	148	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
668	149	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
669	150	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
670	151	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
671	152	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
672	153	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
673	154	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
674	155	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
675	156	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
676	157	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
677	158	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
678	159	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
679	160	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
680	161	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
681	162	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
682	163	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
683	164	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
684	165	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
685	166	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
686	167	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
687	168	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
688	169	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
689	170	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
690	171	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
691	172	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
692	173	4	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
693	1	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
694	2	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
695	3	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
696	4	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
697	5	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
698	6	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
699	7	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
700	8	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
701	9	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
702	10	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
703	11	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
704	12	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
705	13	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
706	14	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
707	15	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
708	16	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
709	17	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
710	18	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
711	19	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
712	20	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
713	21	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
714	22	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
715	23	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
716	24	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
717	25	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
718	26	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
719	27	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
720	28	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
721	29	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
722	30	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
723	31	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
724	32	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
725	33	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
726	34	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
727	35	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
728	36	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
729	37	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
730	38	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
731	39	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
732	40	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
733	41	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
734	42	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
735	43	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
736	44	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
737	45	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
738	46	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
739	47	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
740	48	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
741	49	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
742	50	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
743	51	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
744	52	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
745	53	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
746	54	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
747	55	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
748	56	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
749	57	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
750	58	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
751	59	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
752	60	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
753	61	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
754	62	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
755	63	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
756	64	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
757	65	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
758	66	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
759	67	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
760	68	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
761	69	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
762	70	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
763	71	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
764	72	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
765	73	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
766	74	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
767	75	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
768	76	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
769	77	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
770	78	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
771	79	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
772	80	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
773	81	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
774	82	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
775	83	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
776	84	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
777	85	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
778	86	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
779	87	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
780	88	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
781	89	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
782	90	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
783	91	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
784	92	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
785	93	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
786	94	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
787	95	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
788	96	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
789	97	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
790	98	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
791	99	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
792	100	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
793	101	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
794	102	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
795	103	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
796	104	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
797	105	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
798	106	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
799	107	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
800	108	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
801	109	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
802	110	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
803	111	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
804	112	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
805	113	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
806	114	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
807	115	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
808	116	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
809	117	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
810	118	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
811	119	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
812	120	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
813	121	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
814	122	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
815	123	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
816	124	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
817	125	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
818	126	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
819	127	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
820	128	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
821	129	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
822	130	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
823	131	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
824	132	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
825	133	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
826	134	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
827	135	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
828	136	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
829	137	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
830	138	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
831	139	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
832	140	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
833	141	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
834	142	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
835	143	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
836	144	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
837	145	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
838	146	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
839	147	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
840	148	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
841	149	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
842	150	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
843	151	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
844	152	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
845	153	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
846	154	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
847	155	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
848	156	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
849	157	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
850	158	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
851	159	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
852	160	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
853	161	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
854	162	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
855	163	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
856	164	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
857	165	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
858	166	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
859	167	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
860	168	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
861	169	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
862	170	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
863	171	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
864	172	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
865	173	6	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
866	1	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
867	2	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
868	3	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
869	4	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
870	5	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
871	6	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
872	7	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
873	8	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
874	9	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
875	10	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
876	11	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
877	12	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
878	13	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
879	14	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
880	15	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
881	16	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
882	17	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
883	18	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
884	19	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
885	20	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
886	21	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
887	22	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
888	23	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
889	24	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
890	25	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
891	26	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
892	27	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
893	28	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
894	29	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
895	30	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
896	31	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
897	32	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
898	33	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
899	34	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
900	35	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
901	36	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
902	37	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
903	38	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
904	39	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
905	40	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
906	41	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
907	42	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
908	43	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
909	44	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
910	45	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
911	46	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
912	47	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
913	48	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
914	49	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
915	50	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
916	51	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
917	52	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
918	53	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
919	54	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
920	55	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
921	56	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
922	57	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
923	58	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
924	59	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
925	60	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
926	61	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
927	62	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
928	63	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
929	64	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
930	65	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
931	66	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
932	67	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
933	68	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
934	69	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
935	70	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
936	71	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
937	72	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
938	73	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
939	74	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
940	75	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
941	76	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
942	77	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
943	78	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
944	79	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
945	80	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
946	81	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
947	82	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
948	83	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
949	84	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
950	85	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
951	86	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
952	87	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
953	88	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
954	89	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
955	90	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
956	91	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
957	92	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
958	93	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
959	94	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
960	95	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
961	96	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
962	97	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
963	98	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
964	99	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
965	100	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
966	101	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
967	102	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
968	103	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
969	104	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
970	105	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
971	106	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
972	107	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
973	108	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
974	109	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
975	110	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
976	111	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
977	112	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
978	113	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
979	114	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
980	115	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
981	116	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
982	117	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
983	118	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
984	119	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
985	120	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
986	121	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
987	122	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
988	123	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
989	124	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
990	125	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
991	126	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
992	127	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
993	128	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
994	129	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
995	130	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
996	131	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
997	132	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
998	133	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
999	134	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1000	135	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1001	136	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1002	137	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1003	138	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1004	139	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1005	140	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1006	141	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1007	142	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1008	143	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1009	144	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1010	145	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1011	146	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1012	147	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1013	148	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1014	149	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1015	150	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1016	151	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1017	152	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1018	153	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1019	154	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1020	155	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1021	156	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1022	157	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1023	158	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1024	159	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1025	160	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1026	161	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1027	162	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1028	163	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1029	164	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1030	165	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1031	166	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1032	167	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1033	168	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1034	169	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1035	170	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1036	171	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1037	172	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1038	173	7	2025-11	pending	\N	\N	\N	2025-10-28 14:39:51
1039	2	1	2025-10	pending	\N	\N	\N	2025-10-28 16:49:57
1040	2	2	2025-10	pending	\N	\N	\N	2025-10-28 16:50:04
1041	2	3	2025-10	pending	\N	\N	\N	2025-10-28 16:50:05
1042	9	3	2025-10	pending	\N	\N	\N	2025-10-28 18:56:15
1043	9	4	2025-10	pending	\N	\N	\N	2025-10-28 19:07:19
1044	2	5	2025-10	pending	\N	\N	\N	2025-10-28 20:19:05
1045	2	4	2025-10	pending	\N	\N	\N	2025-10-28 20:19:09
1046	2	7	2025-10	pending	\N	\N	\N	2025-10-28 20:19:17
1047	2	8	2025-10	pending	\N	\N	\N	2025-10-28 20:19:19
1048	2	6	2025-10	pending	\N	\N	\N	2025-10-28 20:53:36
1049	34	1	2025-10	pending	\N	\N	\N	2025-10-29 15:24:33
1050	34	2	2025-10	pending	\N	\N	\N	2025-10-29 15:24:34
\.


--
-- Data for Name: url_changes; Type: TABLE DATA; Schema: public; Owner: jesusramos
--

COPY public.url_changes (id, url_id, change_type, old_value, new_value, detected_at, details) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: jesusramos
--

COPY public.users (id, username, password_hash, full_name, email, active, created_at) FROM stdin;
1	admin	scrypt:32768:8:1$0nCQ5lYOgU8z4GY5$6e2ac6f0c68b6fb039bd7cc01c7eb0414d83399aab67b484fd1150a73fd15e43b344adf06a096386924587f7ace8da769e1db6fc9c7ef94c315ba4ee0a2365ef	Administrador	\N	t	2025-10-29 14:56:43
2	usuario1	scrypt:32768:8:1$9OnFFF2s6aQdblau$081ef9eb42bcb46777d4a3eff9928661b311392adcb90319a3535a50795dfe2c0ac103e8ca59a7b20e71717eebe1c96366837738a961876bf850bd0c53ec90b0	Usuario 1	\N	t	2025-10-29 14:56:44
3	usuario2	scrypt:32768:8:1$wjgWGWwvfo38hGGn$5987fe681e6061a02697bebae72af5ed640f3202db0758acd332378f7b5161066b407e061d010ea9b3ff7399f15b75c34f48b2485c74f146f1d3b1ff8aca5f2a	Usuario 2	\N	t	2025-10-29 14:56:45
\.


--
-- Name: alert_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jesusramos
--

SELECT pg_catalog.setval('public.alert_settings_id_seq', 24, true);


--
-- Name: crawl_runs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jesusramos
--

SELECT pg_catalog.setval('public.crawl_runs_id_seq', 4, true);


--
-- Name: custom_dictionary_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jesusramos
--

SELECT pg_catalog.setval('public.custom_dictionary_id_seq', 1352, true);


--
-- Name: discovered_urls_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jesusramos
--

SELECT pg_catalog.setval('public.discovered_urls_id_seq', 4887, true);


--
-- Name: health_snapshots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jesusramos
--

SELECT pg_catalog.setval('public.health_snapshots_id_seq', 1, true);


--
-- Name: notification_preferences_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jesusramos
--

SELECT pg_catalog.setval('public.notification_preferences_id_seq', 1, true);


--
-- Name: pending_alerts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jesusramos
--

SELECT pg_catalog.setval('public.pending_alerts_id_seq', 24, true);


--
-- Name: quality_check_batches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jesusramos
--

SELECT pg_catalog.setval('public.quality_check_batches_id_seq', 1, true);


--
-- Name: quality_check_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jesusramos
--

SELECT pg_catalog.setval('public.quality_check_config_id_seq', 13, true);


--
-- Name: quality_checks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jesusramos
--

SELECT pg_catalog.setval('public.quality_checks_id_seq', 1044, true);


--
-- Name: sections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jesusramos
--

SELECT pg_catalog.setval('public.sections_id_seq', 173, true);


--
-- Name: task_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jesusramos
--

SELECT pg_catalog.setval('public.task_types_id_seq', 8, true);


--
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jesusramos
--

SELECT pg_catalog.setval('public.tasks_id_seq', 1050, true);


--
-- Name: url_changes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jesusramos
--

SELECT pg_catalog.setval('public.url_changes_id_seq', 1, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jesusramos
--

SELECT pg_catalog.setval('public.users_id_seq', 3, true);


--
-- Name: alert_settings alert_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.alert_settings
    ADD CONSTRAINT alert_settings_pkey PRIMARY KEY (id);


--
-- Name: crawl_runs crawl_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.crawl_runs
    ADD CONSTRAINT crawl_runs_pkey PRIMARY KEY (id);


--
-- Name: custom_dictionary custom_dictionary_pkey; Type: CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.custom_dictionary
    ADD CONSTRAINT custom_dictionary_pkey PRIMARY KEY (id);


--
-- Name: custom_dictionary custom_dictionary_word_lower_key; Type: CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.custom_dictionary
    ADD CONSTRAINT custom_dictionary_word_lower_key UNIQUE (word_lower);


--
-- Name: discovered_urls discovered_urls_pkey; Type: CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.discovered_urls
    ADD CONSTRAINT discovered_urls_pkey PRIMARY KEY (id);


--
-- Name: discovered_urls discovered_urls_url_key; Type: CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.discovered_urls
    ADD CONSTRAINT discovered_urls_url_key UNIQUE (url);


--
-- Name: health_snapshots health_snapshots_pkey; Type: CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.health_snapshots
    ADD CONSTRAINT health_snapshots_pkey PRIMARY KEY (id);


--
-- Name: notification_preferences notification_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.notification_preferences
    ADD CONSTRAINT notification_preferences_pkey PRIMARY KEY (id);


--
-- Name: pending_alerts pending_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.pending_alerts
    ADD CONSTRAINT pending_alerts_pkey PRIMARY KEY (id);


--
-- Name: quality_check_batches quality_check_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.quality_check_batches
    ADD CONSTRAINT quality_check_batches_pkey PRIMARY KEY (id);


--
-- Name: quality_check_config quality_check_config_pkey; Type: CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.quality_check_config
    ADD CONSTRAINT quality_check_config_pkey PRIMARY KEY (id);


--
-- Name: quality_checks quality_checks_pkey; Type: CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.quality_checks
    ADD CONSTRAINT quality_checks_pkey PRIMARY KEY (id);


--
-- Name: sections sections_pkey; Type: CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_pkey PRIMARY KEY (id);


--
-- Name: sections sections_url_key; Type: CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_url_key UNIQUE (url);


--
-- Name: task_types task_types_name_key; Type: CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.task_types
    ADD CONSTRAINT task_types_name_key UNIQUE (name);


--
-- Name: task_types task_types_pkey; Type: CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.task_types
    ADD CONSTRAINT task_types_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_section_id_task_type_id_period_key; Type: CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_section_id_task_type_id_period_key UNIQUE (section_id, task_type_id, period);


--
-- Name: quality_check_config unique_user_check_type; Type: CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.quality_check_config
    ADD CONSTRAINT unique_user_check_type UNIQUE (user_id, check_type);


--
-- Name: url_changes url_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.url_changes
    ADD CONSTRAINT url_changes_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: idx_crawl_runs_started; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_crawl_runs_started ON public.crawl_runs USING btree (started_at DESC);


--
-- Name: idx_crawl_runs_status; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_crawl_runs_status ON public.crawl_runs USING btree (status);


--
-- Name: idx_custom_dict_category; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_custom_dict_category ON public.custom_dictionary USING btree (category);


--
-- Name: idx_custom_dict_frequency; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_custom_dict_frequency ON public.custom_dictionary USING btree (frequency DESC);


--
-- Name: idx_custom_dict_word_lower; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_custom_dict_word_lower ON public.custom_dictionary USING btree (word_lower);


--
-- Name: idx_discovered_urls_active; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_discovered_urls_active ON public.discovered_urls USING btree (active);


--
-- Name: idx_discovered_urls_broken; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_discovered_urls_broken ON public.discovered_urls USING btree (is_broken);


--
-- Name: idx_discovered_urls_crawl_run; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_discovered_urls_crawl_run ON public.discovered_urls USING btree (crawl_run_id);


--
-- Name: idx_discovered_urls_depth; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_discovered_urls_depth ON public.discovered_urls USING btree (depth);


--
-- Name: idx_discovered_urls_parent; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_discovered_urls_parent ON public.discovered_urls USING btree (parent_url_id);


--
-- Name: idx_discovered_urls_priority; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_discovered_urls_priority ON public.discovered_urls USING btree (is_priority);


--
-- Name: idx_health_snapshots_date; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_health_snapshots_date ON public.health_snapshots USING btree (snapshot_date DESC);


--
-- Name: idx_pending_alerts_dismissed; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_pending_alerts_dismissed ON public.pending_alerts USING btree (dismissed);


--
-- Name: idx_pending_alerts_due_date; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_pending_alerts_due_date ON public.pending_alerts USING btree (due_date);


--
-- Name: idx_pending_alerts_task_type; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_pending_alerts_task_type ON public.pending_alerts USING btree (task_type_id);


--
-- Name: idx_quality_check_batches_started; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_quality_check_batches_started ON public.quality_check_batches USING btree (started_at DESC);


--
-- Name: idx_quality_check_batches_status; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_quality_check_batches_status ON public.quality_check_batches USING btree (status);


--
-- Name: idx_quality_check_config_enabled; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_quality_check_config_enabled ON public.quality_check_config USING btree (user_id, enabled, run_after_crawl);


--
-- Name: idx_quality_check_config_user; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_quality_check_config_user ON public.quality_check_config USING btree (user_id);


--
-- Name: idx_quality_checks_checked_at; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_quality_checks_checked_at ON public.quality_checks USING btree (checked_at DESC);


--
-- Name: idx_quality_checks_discovered_url_id; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_quality_checks_discovered_url_id ON public.quality_checks USING btree (discovered_url_id);


--
-- Name: idx_quality_checks_section_id; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_quality_checks_section_id ON public.quality_checks USING btree (section_id);


--
-- Name: idx_quality_checks_section_type; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_quality_checks_section_type ON public.quality_checks USING btree (section_id, check_type);


--
-- Name: idx_quality_checks_status; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_quality_checks_status ON public.quality_checks USING btree (status);


--
-- Name: idx_quality_checks_type; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_quality_checks_type ON public.quality_checks USING btree (check_type);


--
-- Name: idx_url_changes_detected; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_url_changes_detected ON public.url_changes USING btree (detected_at DESC);


--
-- Name: idx_url_changes_type; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_url_changes_type ON public.url_changes USING btree (change_type);


--
-- Name: idx_url_changes_url_id; Type: INDEX; Schema: public; Owner: jesusramos
--

CREATE INDEX idx_url_changes_url_id ON public.url_changes USING btree (url_id);


--
-- Name: alert_settings alert_settings_task_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.alert_settings
    ADD CONSTRAINT alert_settings_task_type_id_fkey FOREIGN KEY (task_type_id) REFERENCES public.task_types(id);


--
-- Name: custom_dictionary custom_dictionary_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.custom_dictionary
    ADD CONSTRAINT custom_dictionary_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id);


--
-- Name: discovered_urls discovered_urls_parent_url_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.discovered_urls
    ADD CONSTRAINT discovered_urls_parent_url_id_fkey FOREIGN KEY (parent_url_id) REFERENCES public.discovered_urls(id) ON DELETE SET NULL;


--
-- Name: discovered_urls fk_discovered_urls_crawl_run; Type: FK CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.discovered_urls
    ADD CONSTRAINT fk_discovered_urls_crawl_run FOREIGN KEY (crawl_run_id) REFERENCES public.crawl_runs(id) ON DELETE SET NULL;


--
-- Name: pending_alerts pending_alerts_task_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.pending_alerts
    ADD CONSTRAINT pending_alerts_task_type_id_fkey FOREIGN KEY (task_type_id) REFERENCES public.task_types(id);


--
-- Name: quality_check_config quality_check_config_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.quality_check_config
    ADD CONSTRAINT quality_check_config_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: quality_checks quality_checks_discovered_url_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.quality_checks
    ADD CONSTRAINT quality_checks_discovered_url_id_fkey FOREIGN KEY (discovered_url_id) REFERENCES public.discovered_urls(id) ON DELETE CASCADE;


--
-- Name: quality_checks quality_checks_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.quality_checks
    ADD CONSTRAINT quality_checks_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.sections(id) ON DELETE CASCADE;


--
-- Name: tasks tasks_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.sections(id);


--
-- Name: tasks tasks_task_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_task_type_id_fkey FOREIGN KEY (task_type_id) REFERENCES public.task_types(id);


--
-- Name: url_changes url_changes_url_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jesusramos
--

ALTER TABLE ONLY public.url_changes
    ADD CONSTRAINT url_changes_url_id_fkey FOREIGN KEY (url_id) REFERENCES public.discovered_urls(id) ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: jesusramos
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict ybEYh36Zynfx7wG6y4zHdp3aNEsepXUGgiL0IYUMfwjsYpeQdMleid57CQrkiyY

