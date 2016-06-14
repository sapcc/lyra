--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.0
-- Dumped by pg_dump version 9.5.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: automations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE automations (
    id integer NOT NULL,
    type character varying NOT NULL,
    name character varying NOT NULL,
    project_id character varying,
    repository character varying,
    repository_revision character varying,
    tags jsonb,
    timeout integer DEFAULT 3600 NOT NULL,
    run_list character varying[],
    chef_attributes jsonb,
    log_level character varying,
    path character varying,
    arguments character varying[],
    environment jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    chef_version character varying
);


--
-- Name: automations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE automations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: automations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE automations_id_seq OWNED BY automations.id;


--
-- Name: que_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE que_jobs (
    priority smallint DEFAULT 100 NOT NULL,
    run_at timestamp with time zone DEFAULT now() NOT NULL,
    job_id bigint NOT NULL,
    job_class text NOT NULL,
    args json DEFAULT '[]'::json NOT NULL,
    error_count integer DEFAULT 0 NOT NULL,
    last_error text,
    queue text DEFAULT ''::text NOT NULL
);


--
-- Name: TABLE que_jobs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE que_jobs IS '3';


--
-- Name: que_jobs_job_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE que_jobs_job_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: que_jobs_job_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE que_jobs_job_id_seq OWNED BY que_jobs.job_id;


--
-- Name: runs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE runs (
    id integer NOT NULL,
    job_id character varying NOT NULL,
    automation_id integer,
    selector character varying,
    repository_revision character varying,
    automation_attributes jsonb,
    state character varying DEFAULT 'preparing'::character varying NOT NULL,
    log character varying,
    jobs character varying[],
    owner jsonb NOT NULL,
    project_id character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: runs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE runs_id_seq OWNED BY runs.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY automations ALTER COLUMN id SET DEFAULT nextval('automations_id_seq'::regclass);


--
-- Name: job_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY que_jobs ALTER COLUMN job_id SET DEFAULT nextval('que_jobs_job_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY runs ALTER COLUMN id SET DEFAULT nextval('runs_id_seq'::regclass);


--
-- Name: automations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY automations
    ADD CONSTRAINT automations_pkey PRIMARY KEY (id);


--
-- Name: que_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY que_jobs
    ADD CONSTRAINT que_jobs_pkey PRIMARY KEY (queue, priority, run_at, job_id);


--
-- Name: runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY runs
    ADD CONSTRAINT runs_pkey PRIMARY KEY (id);


--
-- Name: index_automations_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_automations_on_project_id ON automations USING btree (project_id);


--
-- Name: index_runs_on_automation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_runs_on_automation_id ON runs USING btree (automation_id);


--
-- Name: index_runs_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_runs_on_job_id ON runs USING btree (job_id);


--
-- Name: index_runs_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_runs_on_project_id ON runs USING btree (project_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20151209143356');

INSERT INTO schema_migrations (version) VALUES ('20160120095306');

INSERT INTO schema_migrations (version) VALUES ('20160309121739');

INSERT INTO schema_migrations (version) VALUES ('20160318135530');

INSERT INTO schema_migrations (version) VALUES ('20160613124044');

