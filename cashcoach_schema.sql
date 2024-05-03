--
-- PostgreSQL database dump
--

-- Dumped from database version 15.5
-- Dumped by pg_dump version 16.2

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
-- Name: goalstatus; Type: TYPE; Schema: public; Owner: cashcoach
--

CREATE TYPE public.goalstatus AS ENUM (
    'PENDING',
    'OVERDUE',
    'COMPLETED',
    'UPCOMING'
);


ALTER TYPE public.goalstatus OWNER TO cashcoach;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: cashcoach
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO cashcoach;

--
-- Name: budget_category; Type: TABLE; Schema: public; Owner: cashcoach
--

CREATE TABLE public.budget_category (
    id uuid NOT NULL,
    name character varying NOT NULL,
    description character varying,
    estimated_percentage double precision,
    is_enabled boolean
);


ALTER TABLE public.budget_category OWNER TO cashcoach;

--
-- Name: budget_sub_category; Type: TABLE; Schema: public; Owner: cashcoach
--

CREATE TABLE public.budget_sub_category (
    id uuid NOT NULL,
    name character varying NOT NULL,
    budget_category_id uuid NOT NULL
);


ALTER TABLE public.budget_sub_category OWNER TO cashcoach;

--
-- Name: financial_goal; Type: TABLE; Schema: public; Owner: cashcoach
--

CREATE TABLE public.financial_goal (
    id uuid NOT NULL,
    title character varying(200) NOT NULL,
    description character varying(250),
    target_budget real NOT NULL,
    start_date date,
    target_date date NOT NULL,
    status public.goalstatus,
    progress real NOT NULL,
    complete_at timestamp without time zone,
    firebase_user_id character varying(200),
    created_at timestamp without time zone NOT NULL,
    user_id uuid
);


ALTER TABLE public.financial_goal OWNER TO cashcoach;

--
-- Name: transaction_category; Type: TABLE; Schema: public; Owner: cashcoach
--

CREATE TABLE public.transaction_category (
    id uuid NOT NULL,
    "primary" character varying,
    detailed character varying,
    description character varying,
    budget_category_id uuid,
    budget_sub_category_id uuid
);


ALTER TABLE public.transaction_category OWNER TO cashcoach;

--
-- Name: transaction_category_details; Type: TABLE; Schema: public; Owner: cashcoach
--

CREATE TABLE public.transaction_category_details (
    id uuid NOT NULL,
    reasoning character varying,
    "isTrip" boolean,
    trip_reasoning character varying,
    "isPotentialFraud" boolean,
    fraud_reasoning character varying,
    category_id uuid,
    transaction_id character varying
);


ALTER TABLE public.transaction_category_details OWNER TO cashcoach;

--
-- Name: transaction_cursor; Type: TABLE; Schema: public; Owner: cashcoach
--

CREATE TABLE public.transaction_cursor (
    id uuid NOT NULL,
    cursor character varying,
    user_id uuid,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.transaction_cursor OWNER TO cashcoach;

--
-- Name: transactions; Type: TABLE; Schema: public; Owner: cashcoach
--

CREATE TABLE public.transactions (
    id uuid NOT NULL,
    amount double precision,
    currency_code character varying,
    date date,
    description character varying,
    entry_type character varying,
    status character varying,
    transaction_metadata json,
    provider character varying,
    transaction_id character varying,
    merchant json,
    firebase_user_id character varying(200),
    is_endorsed boolean,
    user_id uuid,
    transaction_category_id uuid NOT NULL,
    transaction_category_details_id uuid,
    account_id character varying(56)
);


ALTER TABLE public.transactions OWNER TO cashcoach;

--
-- Name: unknown_transaction_category; Type: TABLE; Schema: public; Owner: cashcoach
--

CREATE TABLE public.unknown_transaction_category (
    id uuid NOT NULL,
    "primary" character varying,
    detailed character varying,
    created_at timestamp without time zone NOT NULL,
    transaction_id character varying
);


ALTER TABLE public.unknown_transaction_category OWNER TO cashcoach;

--
-- Name: user_account; Type: TABLE; Schema: public; Owner: cashcoach
--

CREATE TABLE public.user_account (
    id character varying(50) NOT NULL,
    name character varying(120),
    provider character varying(20),
    type character varying(24),
    verified boolean,
    "currencyCode" character varying(8),
    user_id uuid
);


ALTER TABLE public.user_account OWNER TO cashcoach;

--
-- Name: user_budget; Type: TABLE; Schema: public; Owner: cashcoach
--

CREATE TABLE public.user_budget (
    id uuid NOT NULL,
    total_revenue double precision,
    month date,
    user_id uuid NOT NULL
);


ALTER TABLE public.user_budget OWNER TO cashcoach;

--
-- Name: user_budget_detail; Type: TABLE; Schema: public; Owner: cashcoach
--

CREATE TABLE public.user_budget_detail (
    id uuid NOT NULL,
    category_name character varying,
    category_amount double precision,
    budget_category_id uuid,
    user_budget_id uuid NOT NULL
);


ALTER TABLE public.user_budget_detail OWNER TO cashcoach;

--
-- Name: user_budget_preference; Type: TABLE; Schema: public; Owner: cashcoach
--

CREATE TABLE public.user_budget_preference (
    id uuid NOT NULL,
    preferred_percentage double precision,
    user_id uuid NOT NULL,
    budget_category_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.user_budget_preference OWNER TO cashcoach;

--
-- Name: user_budget_sub_category; Type: TABLE; Schema: public; Owner: cashcoach
--

CREATE TABLE public.user_budget_sub_category (
    id uuid NOT NULL,
    planned_amount_percentage double precision,
    budget_sub_category_id uuid,
    user_budget_detail_id uuid
);


ALTER TABLE public.user_budget_sub_category OWNER TO cashcoach;

--
-- Name: user_location; Type: TABLE; Schema: public; Owner: cashcoach
--

CREATE TABLE public.user_location (
    id uuid NOT NULL,
    street_number character varying,
    route character varying,
    city character varying,
    state character varying,
    postal_code character varying,
    country character varying,
    user_id uuid
);


ALTER TABLE public.user_location OWNER TO cashcoach;

--
-- Name: user_profile; Type: TABLE; Schema: public; Owner: cashcoach
--

CREATE TABLE public.user_profile (
    id uuid NOT NULL,
    firebase_user_id character varying NOT NULL,
    "firstName" character varying,
    "lastName" character varying,
    email character varying NOT NULL,
    password character varying,
    "profilePic" character varying,
    "phoneNumber" character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.user_profile OWNER TO cashcoach;

--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: budget_category budget_category_id_key; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.budget_category
    ADD CONSTRAINT budget_category_id_key UNIQUE (id);


--
-- Name: budget_category budget_category_pkey; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.budget_category
    ADD CONSTRAINT budget_category_pkey PRIMARY KEY (id);


--
-- Name: budget_sub_category budget_sub_category_id_key; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.budget_sub_category
    ADD CONSTRAINT budget_sub_category_id_key UNIQUE (id);


--
-- Name: budget_sub_category budget_sub_category_pkey; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.budget_sub_category
    ADD CONSTRAINT budget_sub_category_pkey PRIMARY KEY (id);


--
-- Name: financial_goal financial_goal_id_key; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.financial_goal
    ADD CONSTRAINT financial_goal_id_key UNIQUE (id);


--
-- Name: financial_goal financial_goal_pkey; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.financial_goal
    ADD CONSTRAINT financial_goal_pkey PRIMARY KEY (id);


--
-- Name: transaction_category_details transaction_category_details_id_key; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.transaction_category_details
    ADD CONSTRAINT transaction_category_details_id_key UNIQUE (id);


--
-- Name: transaction_category_details transaction_category_details_pkey; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.transaction_category_details
    ADD CONSTRAINT transaction_category_details_pkey PRIMARY KEY (id);


--
-- Name: transaction_category transaction_category_id_key; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.transaction_category
    ADD CONSTRAINT transaction_category_id_key UNIQUE (id);


--
-- Name: transaction_category transaction_category_pkey; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.transaction_category
    ADD CONSTRAINT transaction_category_pkey PRIMARY KEY (id);


--
-- Name: transaction_cursor transaction_cursor_id_key; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.transaction_cursor
    ADD CONSTRAINT transaction_cursor_id_key UNIQUE (id);


--
-- Name: transaction_cursor transaction_cursor_pkey; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.transaction_cursor
    ADD CONSTRAINT transaction_cursor_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_id_key; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_id_key UNIQUE (id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_transaction_id_key; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_transaction_id_key UNIQUE (transaction_id);


--
-- Name: unknown_transaction_category unknown_transaction_category_id_key; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.unknown_transaction_category
    ADD CONSTRAINT unknown_transaction_category_id_key UNIQUE (id);


--
-- Name: unknown_transaction_category unknown_transaction_category_pkey; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.unknown_transaction_category
    ADD CONSTRAINT unknown_transaction_category_pkey PRIMARY KEY (id);


--
-- Name: user_account user_account_id_key; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT user_account_id_key UNIQUE (id);


--
-- Name: user_account user_account_pkey; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT user_account_pkey PRIMARY KEY (id);


--
-- Name: user_budget_detail user_budget_detail_id_key; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_budget_detail
    ADD CONSTRAINT user_budget_detail_id_key UNIQUE (id);


--
-- Name: user_budget_detail user_budget_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_budget_detail
    ADD CONSTRAINT user_budget_detail_pkey PRIMARY KEY (id);


--
-- Name: user_budget user_budget_id_key; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_budget
    ADD CONSTRAINT user_budget_id_key UNIQUE (id);


--
-- Name: user_budget user_budget_pkey; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_budget
    ADD CONSTRAINT user_budget_pkey PRIMARY KEY (id);


--
-- Name: user_budget_preference user_budget_preference_id_key; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_budget_preference
    ADD CONSTRAINT user_budget_preference_id_key UNIQUE (id);


--
-- Name: user_budget_preference user_budget_preference_pkey; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_budget_preference
    ADD CONSTRAINT user_budget_preference_pkey PRIMARY KEY (id);


--
-- Name: user_budget_sub_category user_budget_sub_category_id_key; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_budget_sub_category
    ADD CONSTRAINT user_budget_sub_category_id_key UNIQUE (id);


--
-- Name: user_budget_sub_category user_budget_sub_category_pkey; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_budget_sub_category
    ADD CONSTRAINT user_budget_sub_category_pkey PRIMARY KEY (id);


--
-- Name: user_location user_location_id_key; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_location
    ADD CONSTRAINT user_location_id_key UNIQUE (id);


--
-- Name: user_location user_location_pkey; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_location
    ADD CONSTRAINT user_location_pkey PRIMARY KEY (id);


--
-- Name: user_profile user_profile_email_key; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_profile
    ADD CONSTRAINT user_profile_email_key UNIQUE (email);


--
-- Name: user_profile user_profile_id_key; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_profile
    ADD CONSTRAINT user_profile_id_key UNIQUE (id);


--
-- Name: user_profile user_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_profile
    ADD CONSTRAINT user_profile_pkey PRIMARY KEY (id);


--
-- Name: budget_sub_category budget_sub_category_budget_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.budget_sub_category
    ADD CONSTRAINT budget_sub_category_budget_category_id_fkey FOREIGN KEY (budget_category_id) REFERENCES public.budget_category(id) ON DELETE CASCADE;


--
-- Name: financial_goal financial_goal_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.financial_goal
    ADD CONSTRAINT financial_goal_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profile(id) ON DELETE CASCADE;


--
-- Name: transaction_category transaction_category_budget_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.transaction_category
    ADD CONSTRAINT transaction_category_budget_category_id_fkey FOREIGN KEY (budget_category_id) REFERENCES public.budget_category(id) ON DELETE SET NULL;


--
-- Name: transaction_category transaction_category_budget_sub_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.transaction_category
    ADD CONSTRAINT transaction_category_budget_sub_category_id_fkey FOREIGN KEY (budget_sub_category_id) REFERENCES public.budget_sub_category(id) ON DELETE SET NULL;


--
-- Name: transaction_category_details transaction_category_details_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.transaction_category_details
    ADD CONSTRAINT transaction_category_details_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.transaction_category(id) ON DELETE SET NULL;


--
-- Name: transaction_cursor transaction_cursor_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.transaction_cursor
    ADD CONSTRAINT transaction_cursor_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profile(id) ON DELETE SET NULL;


--
-- Name: transactions transactions_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.user_account(id) ON DELETE SET NULL;


--
-- Name: transactions transactions_transaction_category_details_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_transaction_category_details_id_fkey FOREIGN KEY (transaction_category_details_id) REFERENCES public.transaction_category_details(id) ON DELETE SET NULL;


--
-- Name: transactions transactions_transaction_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_transaction_category_id_fkey FOREIGN KEY (transaction_category_id) REFERENCES public.transaction_category(id) ON DELETE SET NULL;


--
-- Name: transactions transactions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profile(id) ON DELETE SET NULL;


--
-- Name: user_account user_account_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT user_account_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profile(id) ON DELETE SET NULL;


--
-- Name: user_budget_detail user_budget_detail_budget_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_budget_detail
    ADD CONSTRAINT user_budget_detail_budget_category_id_fkey FOREIGN KEY (budget_category_id) REFERENCES public.budget_category(id);


--
-- Name: user_budget_detail user_budget_detail_user_budget_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_budget_detail
    ADD CONSTRAINT user_budget_detail_user_budget_id_fkey FOREIGN KEY (user_budget_id) REFERENCES public.user_budget(id) ON DELETE CASCADE;


--
-- Name: user_budget_preference user_budget_preference_budget_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_budget_preference
    ADD CONSTRAINT user_budget_preference_budget_category_id_fkey FOREIGN KEY (budget_category_id) REFERENCES public.budget_category(id) ON DELETE CASCADE;


--
-- Name: user_budget_preference user_budget_preference_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_budget_preference
    ADD CONSTRAINT user_budget_preference_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profile(id) ON DELETE CASCADE;


--
-- Name: user_budget_sub_category user_budget_sub_category_budget_sub_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_budget_sub_category
    ADD CONSTRAINT user_budget_sub_category_budget_sub_category_id_fkey FOREIGN KEY (budget_sub_category_id) REFERENCES public.budget_sub_category(id);


--
-- Name: user_budget_sub_category user_budget_sub_category_user_budget_detail_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_budget_sub_category
    ADD CONSTRAINT user_budget_sub_category_user_budget_detail_id_fkey FOREIGN KEY (user_budget_detail_id) REFERENCES public.user_budget_detail(id) ON DELETE CASCADE;


--
-- Name: user_budget user_budget_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_budget
    ADD CONSTRAINT user_budget_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profile(id);


--
-- Name: user_location user_location_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cashcoach
--

ALTER TABLE ONLY public.user_location
    ADD CONSTRAINT user_location_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profile(id) ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO cloudsqlsuperuser;


--
-- Name: FUNCTION pg_replication_origin_advance(text, pg_lsn); Type: ACL; Schema: pg_catalog; Owner: cloudsqladmin
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_advance(text, pg_lsn) TO cloudsqlsuperuser;


--
-- Name: FUNCTION pg_replication_origin_create(text); Type: ACL; Schema: pg_catalog; Owner: cloudsqladmin
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_create(text) TO cloudsqlsuperuser;


--
-- Name: FUNCTION pg_replication_origin_drop(text); Type: ACL; Schema: pg_catalog; Owner: cloudsqladmin
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_drop(text) TO cloudsqlsuperuser;


--
-- Name: FUNCTION pg_replication_origin_oid(text); Type: ACL; Schema: pg_catalog; Owner: cloudsqladmin
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_oid(text) TO cloudsqlsuperuser;


--
-- Name: FUNCTION pg_replication_origin_progress(text, boolean); Type: ACL; Schema: pg_catalog; Owner: cloudsqladmin
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_progress(text, boolean) TO cloudsqlsuperuser;


--
-- Name: FUNCTION pg_replication_origin_session_is_setup(); Type: ACL; Schema: pg_catalog; Owner: cloudsqladmin
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_session_is_setup() TO cloudsqlsuperuser;


--
-- Name: FUNCTION pg_replication_origin_session_progress(boolean); Type: ACL; Schema: pg_catalog; Owner: cloudsqladmin
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_session_progress(boolean) TO cloudsqlsuperuser;


--
-- Name: FUNCTION pg_replication_origin_session_reset(); Type: ACL; Schema: pg_catalog; Owner: cloudsqladmin
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_session_reset() TO cloudsqlsuperuser;


--
-- Name: FUNCTION pg_replication_origin_session_setup(text); Type: ACL; Schema: pg_catalog; Owner: cloudsqladmin
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_session_setup(text) TO cloudsqlsuperuser;


--
-- Name: FUNCTION pg_replication_origin_xact_reset(); Type: ACL; Schema: pg_catalog; Owner: cloudsqladmin
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_xact_reset() TO cloudsqlsuperuser;


--
-- Name: FUNCTION pg_replication_origin_xact_setup(pg_lsn, timestamp with time zone); Type: ACL; Schema: pg_catalog; Owner: cloudsqladmin
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_xact_setup(pg_lsn, timestamp with time zone) TO cloudsqlsuperuser;


--
-- Name: FUNCTION pg_show_replication_origin_status(OUT local_id oid, OUT external_id text, OUT remote_lsn pg_lsn, OUT local_lsn pg_lsn); Type: ACL; Schema: pg_catalog; Owner: cloudsqladmin
--

GRANT ALL ON FUNCTION pg_catalog.pg_show_replication_origin_status(OUT local_id oid, OUT external_id text, OUT remote_lsn pg_lsn, OUT local_lsn pg_lsn) TO cloudsqlsuperuser;


--
-- PostgreSQL database dump complete
--

