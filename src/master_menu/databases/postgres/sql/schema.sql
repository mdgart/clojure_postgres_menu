--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.2
-- Dumped by pg_dump version 9.6.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: ltree; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS ltree WITH SCHEMA public;


--
-- Name: EXTENSION ltree; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION ltree IS 'data type for hierarchical tree-like structures';


SET search_path = public, pg_catalog;

--
-- Name: status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE status AS ENUM (
    'New',
    'Pending',
    'Live',
    'Requested',
    'Failed',
    'Deleted',
    'Rejected'
);


ALTER TYPE status OWNER TO postgres;

--
-- Name: get_calculated_si_node_path(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_calculated_si_node_path(param_si_id integer) RETURNS ltree
    LANGUAGE sql
    AS $_$
SELECT CASE WHEN s.parent_id IS NULL THEN s.id::text::ltree
            ELSE get_calculated_si_node_path(s.parent_id) || s.id::text END
FROM section_item As s
WHERE s.id = $1;
$_$;


ALTER FUNCTION public.get_calculated_si_node_path(param_si_id integer) OWNER TO postgres;

--
-- Name: trig_update_si_node_path(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION trig_update_si_node_path() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
        IF (COALESCE(OLD.parent_id,0) != COALESCE(NEW.parent_id,0)  OR  NEW.id != OLD.id) THEN
            -- update all nodes that are children of this one including this one
            UPDATE section_item SET path = get_calculated_si_node_path(id)
                WHERE OLD.path  @> section_item.path;
        END IF;
  ELSIF TG_OP = 'INSERT' THEN
        UPDATE section_item SET path = get_calculated_si_node_path(NEW.id) WHERE section_item.id = NEW.id;
  END IF;

  RETURN NEW;
END
$$;


ALTER FUNCTION public.trig_update_si_node_path() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account_section_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE account_section_item (
    id integer NOT NULL,
    section_item_id integer,
    mf_account_id text,
    provider text
);


ALTER TABLE account_section_item OWNER TO postgres;

--
-- Name: account_section_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE account_section_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE account_section_item_id_seq OWNER TO postgres;

--
-- Name: account_section_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE account_section_item_id_seq OWNED BY account_section_item.id;


--
-- Name: location_section_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE location_section_item (
    id integer NOT NULL,
    mf_location_id text,
    hide boolean DEFAULT false,
    price jsonb,
    section_item_id integer,
    status status DEFAULT 'New'::status,
    "timestamp" timestamp with time zone DEFAULT now()
);


ALTER TABLE location_section_item OWNER TO postgres;

--
-- Name: location_section_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE location_section_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE location_section_item_id_seq OWNER TO postgres;

--
-- Name: location_section_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE location_section_item_id_seq OWNED BY location_section_item.id;


--
-- Name: section_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE section_item (
    id integer NOT NULL,
    labels jsonb NOT NULL,
    attributes jsonb,
    price jsonb,
    path ltree,
    parent_id integer
);


ALTER TABLE section_item OWNER TO postgres;

--
-- Name: section_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE section_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE section_item_id_seq OWNER TO postgres;

--
-- Name: section_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE section_item_id_seq OWNED BY section_item.id;


--
-- Name: account_section_item id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY account_section_item ALTER COLUMN id SET DEFAULT nextval('account_section_item_id_seq'::regclass);


--
-- Name: location_section_item id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY location_section_item ALTER COLUMN id SET DEFAULT nextval('location_section_item_id_seq'::regclass);


--
-- Name: section_item id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY section_item ALTER COLUMN id SET DEFAULT nextval('section_item_id_seq'::regclass);


--
-- Data for Name: account_section_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY account_section_item (id, section_item_id, mf_account_id, provider) FROM stdin;
\.


--
-- Name: account_section_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('account_section_item_id_seq', 1, false);


--
-- Data for Name: location_section_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY location_section_item (id, mf_location_id, hide, price, section_item_id, status, "timestamp") FROM stdin;
\.


--
-- Name: location_section_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('location_section_item_id_seq', 1, false);


--
-- Data for Name: section_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY section_item (id, labels, attributes, price, path, parent_id) FROM stdin;
\.


--
-- Name: section_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('section_item_id_seq', 1, false);


--
-- Name: account_section_item account_section_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY account_section_item
    ADD CONSTRAINT account_section_item_pkey PRIMARY KEY (id);


--
-- Name: location_section_item location_section_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY location_section_item
    ADD CONSTRAINT location_section_item_pkey PRIMARY KEY (id);


--
-- Name: section_item section_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY section_item
    ADD CONSTRAINT section_item_pkey PRIMARY KEY (id);


--
-- Name: idx_location_section_item_section_item_id_mf_location_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_location_section_item_section_item_id_mf_location_id ON location_section_item USING btree (section_item_id, mf_location_id);


--
-- Name: idx_section_item_node_path_btree_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_section_item_node_path_btree_idx ON section_item USING btree (path);


--
-- Name: idx_section_item_node_path_gist_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_section_item_node_path_gist_idx ON section_item USING gist (path);


--
-- Name: section_item trig01_update_si_node_path; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trig01_update_si_node_path AFTER INSERT OR UPDATE OF id, parent_id ON section_item FOR EACH ROW EXECUTE PROCEDURE trig_update_si_node_path();


--
-- Name: account_section_item account_section_item_section_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY account_section_item
    ADD CONSTRAINT account_section_item_section_item_id_fkey FOREIGN KEY (section_item_id) REFERENCES section_item(id) ON DELETE CASCADE;


--
-- Name: location_section_item location_section_item_section_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY location_section_item
    ADD CONSTRAINT location_section_item_section_item_id_fkey FOREIGN KEY (section_item_id) REFERENCES section_item(id) ON DELETE CASCADE;


--
-- Name: section_item section_item_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY section_item
    ADD CONSTRAINT section_item_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES section_item(id) ON DELETE CASCADE;


--
-- Name: public; Type: ACL; Schema: -; Owner: mdgart
--

GRANT ALL ON SCHEMA public TO postgres;


--
-- PostgreSQL database dump complete
--

