--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.14
-- Dumped by pg_dump version 9.3.1
-- Started on 2014-10-22 18:01:53 BRT

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 166 (class 3079 OID 11647)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 1885 (class 0 OID 0)
-- Dependencies: 166
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 163 (class 1259 OID 21447)
-- Name: curriculums; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE curriculums (
    id integer NOT NULL,
    id16 character varying(255),
    id10 character varying(255),
    lattes_updated_at date,
    degree character varying(255),
    xml xml,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.curriculums OWNER TO postgres;

--
-- TOC entry 162 (class 1259 OID 21445)
-- Name: curriculums_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE curriculums_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.curriculums_id_seq OWNER TO postgres;

--
-- TOC entry 1886 (class 0 OID 0)
-- Dependencies: 162
-- Name: curriculums_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE curriculums_id_seq OWNED BY curriculums.id;


--
-- TOC entry 161 (class 1259 OID 21439)
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO postgres;

--
-- TOC entry 165 (class 1259 OID 21458)
-- Name: updates; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE updates (
    id integer NOT NULL,
    lattes_updated_at date,
    curriculum_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.updates OWNER TO postgres;

--
-- TOC entry 164 (class 1259 OID 21456)
-- Name: updates_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE updates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.updates_id_seq OWNER TO postgres;

--
-- TOC entry 1887 (class 0 OID 0)
-- Dependencies: 164
-- Name: updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE updates_id_seq OWNED BY updates.id;


--
-- TOC entry 1764 (class 2604 OID 21450)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY curriculums ALTER COLUMN id SET DEFAULT nextval('curriculums_id_seq'::regclass);


--
-- TOC entry 1765 (class 2604 OID 21461)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY updates ALTER COLUMN id SET DEFAULT nextval('updates_id_seq'::regclass);



--
-- TOC entry 1888 (class 0 OID 0)
-- Dependencies: 162
-- Name: curriculums_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('curriculums_id_seq', 1, true);


--
-- TOC entry 1889 (class 0 OID 0)
-- Dependencies: 164
-- Name: updates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('updates_id_seq', 1, true);


--
-- TOC entry 1768 (class 2606 OID 21455)
-- Name: curriculums_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY curriculums
    ADD CONSTRAINT curriculums_pkey PRIMARY KEY (id);


--
-- TOC entry 1771 (class 2606 OID 21463)
-- Name: updates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY updates
    ADD CONSTRAINT updates_pkey PRIMARY KEY (id);


--
-- TOC entry 1769 (class 1259 OID 21464)
-- Name: index_updates_on_curriculum_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_updates_on_curriculum_id ON updates USING btree (curriculum_id);


--
-- TOC entry 1766 (class 1259 OID 21442)
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- TOC entry 1884 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2014-10-22 18:01:53 BRT

--
-- PostgreSQL database dump complete
--

