--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.9
-- Dumped by pg_dump version 9.6.9

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
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


--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: addresses_country; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.addresses_country AS ENUM (
    'AD',
    'AE',
    'AF',
    'AG',
    'AI',
    'AL',
    'AM',
    'AO',
    'AQ',
    'AR',
    'AS',
    'AT',
    'AU',
    'AW',
    'AX',
    'AZ',
    'BA',
    'BB',
    'BD',
    'BE',
    'BF',
    'BG',
    'BH',
    'BI',
    'BJ',
    'BL',
    'BM',
    'BN',
    'BO',
    'BQ',
    'BR',
    'BS',
    'BT',
    'BV',
    'BW',
    'BY',
    'BZ',
    'CA',
    'CC',
    'CD',
    'CF',
    'CG',
    'CH',
    'CI',
    'CK',
    'CL',
    'CM',
    'CN',
    'CO',
    'CR',
    'CU',
    'CV',
    'CW',
    'CX',
    'CY',
    'CZ',
    'DE',
    'DJ',
    'DK',
    'DM',
    'DO',
    'DZ',
    'EC',
    'EE',
    'EG',
    'EH',
    'ER',
    'ES',
    'ET',
    'FI',
    'FJ',
    'FK',
    'FM',
    'FO',
    'FR',
    'GA',
    'GB',
    'GD',
    'GE',
    'GF',
    'GG',
    'GH',
    'GI',
    'GL',
    'GM',
    'GN',
    'GP',
    'GQ',
    'GR',
    'GS',
    'GT',
    'GU',
    'GW',
    'GY',
    'HK',
    'HM',
    'HN',
    'HR',
    'HT',
    'HU',
    'ID',
    'IE',
    'IL',
    'IM',
    'IN',
    'IO',
    'IQ',
    'IR',
    'IS',
    'IT',
    'JE',
    'JM',
    'JO',
    'JP',
    'KE',
    'KG',
    'KH',
    'KI',
    'KM',
    'KN',
    'KP',
    'KR',
    'KW',
    'KY',
    'KZ',
    'LA',
    'LB',
    'LC',
    'LI',
    'LK',
    'LR',
    'LS',
    'LT',
    'LU',
    'LV',
    'LY',
    'MA',
    'MC',
    'MD',
    'ME',
    'MF',
    'MG',
    'MH',
    'MK',
    'ML',
    'MM',
    'MN',
    'MO',
    'MP',
    'MQ',
    'MR',
    'MS',
    'MT',
    'MU',
    'MV',
    'MW',
    'MX',
    'MY',
    'MZ',
    'NA',
    'NC',
    'NE',
    'NF',
    'NG',
    'NI',
    'NL',
    'NO',
    'NP',
    'NR',
    'NU',
    'NZ',
    'OM',
    'PA',
    'PE',
    'PF',
    'PG',
    'PH',
    'PK',
    'PL',
    'PM',
    'PN',
    'PR',
    'PS',
    'PT',
    'PW',
    'PY',
    'QA',
    'RE',
    'RO',
    'RS',
    'RU',
    'RW',
    'SA',
    'SB',
    'SC',
    'SD',
    'SE',
    'SG',
    'SH',
    'SI',
    'SJ',
    'SK',
    'SL',
    'SM',
    'SN',
    'SO',
    'SR',
    'SS',
    'ST',
    'SV',
    'SX',
    'SY',
    'SZ',
    'TC',
    'TD',
    'TF',
    'TG',
    'TH',
    'TJ',
    'TK',
    'TL',
    'TM',
    'TN',
    'TO',
    'TR',
    'TT',
    'TV',
    'TW',
    'TZ',
    'UA',
    'UG',
    'UM',
    'US',
    'UY',
    'UZ',
    'VA',
    'VC',
    'VE',
    'VG',
    'VI',
    'VN',
    'VU',
    'WF',
    'WS',
    'YE',
    'YT',
    'ZA',
    'ZM',
    'ZW'
);


--
-- Name: billing_items_contract_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.billing_items_contract_type AS ENUM (
    'power_taker',
    'third_party',
    'gap'
);


--
-- Name: billings_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.billings_status AS ENUM (
    'open',
    'calculated',
    'delivered',
    'settled',
    'closed'
);


--
-- Name: contracts_renewable_energy_law_taxation; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.contracts_renewable_energy_law_taxation AS ENUM (
    'F',
    'R',
    'N'
);


--
-- Name: formula_parts_operator; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.formula_parts_operator AS ENUM (
    '+',
    '-'
);


--
-- Name: meters_datasource; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.meters_datasource AS ENUM (
    'standard_profile',
    'discovergy',
    'virtual'
);


--
-- Name: meters_direction_number; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.meters_direction_number AS ENUM (
    'ERZ',
    'ZRZ'
);


--
-- Name: meters_edifact_cycle_interval; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.meters_edifact_cycle_interval AS ENUM (
    'MONTHLY',
    'QUARTERLY',
    'HALF_YEARLY',
    'YEARLY'
);


--
-- Name: meters_edifact_data_logging; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.meters_edifact_data_logging AS ENUM (
    'Z04',
    'Z05'
);


--
-- Name: meters_edifact_measurement_method; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.meters_edifact_measurement_method AS ENUM (
    'AMR',
    'MMR'
);


--
-- Name: meters_edifact_meter_size; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.meters_edifact_meter_size AS ENUM (
    'Z01',
    'Z02',
    'Z03'
);


--
-- Name: meters_edifact_metering_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.meters_edifact_metering_type AS ENUM (
    'AHZ',
    'WSZ',
    'LAZ',
    'MAZ',
    'EHZ',
    'IVA'
);


--
-- Name: meters_edifact_mounting_method; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.meters_edifact_mounting_method AS ENUM (
    'BKE',
    'DPA',
    'HS'
);


--
-- Name: meters_edifact_tariff; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.meters_edifact_tariff AS ENUM (
    'ETZ',
    'ZTZ',
    'NTZ'
);


--
-- Name: meters_edifact_voltage_level; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.meters_edifact_voltage_level AS ENUM (
    'E06',
    'E05',
    'E04',
    'E03'
);


--
-- Name: meters_manufacturer_name; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.meters_manufacturer_name AS ENUM (
    'easy_meter',
    'other'
);


--
-- Name: meters_ownership; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.meters_ownership AS ENUM (
    'BUZZN',
    'FOREIGN_OWNERSHIP',
    'CUSTOMER',
    'LEASED',
    'BOUGHT'
);


--
-- Name: organization_market_functions_function; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.organization_market_functions_function AS ENUM (
    'distribution_system_operator',
    'electricity_supplier',
    'metering_point_operator',
    'metering_service_provider',
    'other',
    'power_giver',
    'power_taker',
    'transmission_system_operator'
);


--
-- Name: payments_cycle; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.payments_cycle AS ENUM (
    'monthly',
    'yearly',
    'once'
);


--
-- Name: persons_preferred_language; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.persons_preferred_language AS ENUM (
    'de',
    'en'
);


--
-- Name: persons_prefix; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.persons_prefix AS ENUM (
    'F',
    'M'
);


--
-- Name: persons_title; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.persons_title AS ENUM (
    'Prof.',
    'Dr.',
    'Prof. Dr.'
);


--
-- Name: readings_quality; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.readings_quality AS ENUM (
    '20',
    '67',
    '79',
    '187',
    '220',
    '201'
);


--
-- Name: readings_read_by; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.readings_read_by AS ENUM (
    'BN',
    'SN',
    'SG',
    'VNB'
);


--
-- Name: readings_reason; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.readings_reason AS ENUM (
    'IOM',
    'COM1',
    'COM2',
    'ROM',
    'PMR',
    'COT',
    'COS',
    'CMP',
    'COB'
);


--
-- Name: readings_source; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.readings_source AS ENUM (
    'SM',
    'MAN'
);


--
-- Name: readings_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.readings_status AS ENUM (
    'Z83',
    'Z84',
    'Z86'
);


--
-- Name: readings_unit; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.readings_unit AS ENUM (
    'Wh',
    'W',
    'm³'
);


--
-- Name: registers_direction; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.registers_direction AS ENUM (
    'in',
    'out'
);


--
-- Name: registers_label; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.registers_label AS ENUM (
    'CONSUMPTION',
    'CONSUMPTION_COMMON',
    'DEMARCATION_PV',
    'DEMARCATION_CHP',
    'DEMARCATION_WIND',
    'DEMARCATION_WATER',
    'PRODUCTION_PV',
    'PRODUCTION_CHP',
    'PRODUCTION_WIND',
    'PRODUCTION_WATER',
    'GRID_CONSUMPTION',
    'GRID_FEEDING',
    'GRID_CONSUMPTION_CORRECTED',
    'GRID_FEEDING_CORRECTED',
    'OTHER'
);


--
-- Name: roles_name; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.roles_name AS ENUM (
    'BUZZN_OPERATOR',
    'GROUP_OWNER',
    'GROUP_ADMIN',
    'GROUP_MEMBER',
    'GROUP_ENERGY_MENTOR',
    'SELF',
    'CONTRACT',
    'ORGANIZATION'
);


--
-- Name: templates_name; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.templates_name AS ENUM (
    '01_messvertrag',
    'invoice',
    'minimal'
);


--
-- Name: rodauth_get_previous_salt(bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rodauth_get_previous_salt(acct_id bigint) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO public, pg_temp
    AS $$
DECLARE salt text;
BEGIN
SELECT substr(password_hash, 0, 30) INTO salt 
FROM account_previous_password_hashes
WHERE acct_id = id;
RETURN salt;
END;
$$;


--
-- Name: rodauth_get_salt(bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rodauth_get_salt(acct_id bigint) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO public, pg_temp
    AS $$
DECLARE salt text;
BEGIN
SELECT substr(password_hash, 0, 30) INTO salt 
FROM account_password_hashes
WHERE acct_id = id;
RETURN salt;
END;
$$;


--
-- Name: rodauth_previous_password_hash_match(bigint, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rodauth_previous_password_hash_match(acct_id bigint, hash text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO public, pg_temp
    AS $$
DECLARE valid boolean;
BEGIN
SELECT password_hash = hash INTO valid 
FROM account_previous_password_hashes
WHERE acct_id = id;
RETURN valid;
END;
$$;


--
-- Name: rodauth_valid_password_hash(bigint, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rodauth_valid_password_hash(acct_id bigint, hash text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO public, pg_temp
    AS $$
DECLARE valid boolean;
BEGIN
SELECT password_hash = hash INTO valid 
FROM account_password_hashes
WHERE acct_id = id;
RETURN valid;
END;
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account_login_change_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_login_change_keys (
    id bigint NOT NULL,
    key text NOT NULL,
    login text NOT NULL,
    deadline timestamp without time zone DEFAULT ((now())::timestamp without time zone + '1 day'::interval) NOT NULL
);


--
-- Name: account_password_change_times; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_password_change_times (
    id bigint NOT NULL,
    changed_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: account_password_hashes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_password_hashes (
    id bigint NOT NULL,
    password_hash text NOT NULL
);


--
-- Name: account_password_reset_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_password_reset_keys (
    id bigint NOT NULL,
    key text NOT NULL,
    deadline timestamp without time zone DEFAULT ((now())::timestamp without time zone + '1 day'::interval) NOT NULL
);


--
-- Name: account_previous_password_hashes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_previous_password_hashes (
    id bigint NOT NULL,
    account_id bigint,
    password_hash text NOT NULL
);


--
-- Name: account_previous_password_hashes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.account_previous_password_hashes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_previous_password_hashes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.account_previous_password_hashes_id_seq OWNED BY public.account_previous_password_hashes.id;


--
-- Name: account_remember_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_remember_keys (
    id bigint NOT NULL,
    key text NOT NULL,
    deadline timestamp without time zone DEFAULT ((now())::timestamp without time zone + '14 days'::interval) NOT NULL
);


--
-- Name: account_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_statuses (
    id integer NOT NULL,
    name text NOT NULL
);


--
-- Name: account_verification_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_verification_keys (
    id bigint NOT NULL,
    key text NOT NULL,
    requested_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id bigint NOT NULL,
    status_id integer DEFAULT 1 NOT NULL,
    email public.citext NOT NULL,
    person_id integer NOT NULL,
    CONSTRAINT valid_email CHECK ((email OPERATOR(public.~) '^[^,;@ \r\n]+@[^,@; \r\n]+\.[^,@; \r\n]+$'::public.citext))
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.accounts_id_seq OWNED BY public.accounts.id;


--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.addresses (
    id integer NOT NULL,
    street character varying(64) NOT NULL,
    zip character varying(16) NOT NULL,
    city character varying(64) NOT NULL,
    addition character varying(64),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    country public.addresses_country
);


--
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.addresses_id_seq OWNED BY public.addresses.id;


--
-- Name: bank_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bank_accounts (
    id integer NOT NULL,
    holder character varying(64) NOT NULL,
    iban character varying(32) NOT NULL,
    bank_name character varying(64),
    bic character varying(16),
    direct_debit boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    owner_person_id integer,
    owner_organization_id integer,
    CONSTRAINT check_bank_account_owner CHECK (((NOT ((owner_person_id IS NOT NULL) AND (owner_organization_id IS NOT NULL))) OR ((owner_person_id IS NULL) AND (owner_organization_id IS NULL))))
);


--
-- Name: bank_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bank_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bank_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bank_accounts_id_seq OWNED BY public.bank_accounts.id;


--
-- Name: banks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.banks (
    id integer NOT NULL,
    blz character varying(32) NOT NULL,
    description character varying(128) NOT NULL,
    zip character varying(16) NOT NULL,
    place character varying(64) NOT NULL,
    name character varying(64) NOT NULL,
    bic character varying(16) NOT NULL
);


--
-- Name: banks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.banks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: banks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.banks_id_seq OWNED BY public.banks.id;


--
-- Name: billing_cycles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billing_cycles (
    id integer NOT NULL,
    name character varying(64) NOT NULL,
    begin_date date NOT NULL,
    end_date date NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    localpool_id integer NOT NULL
);


--
-- Name: billing_cycles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.billing_cycles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: billing_cycles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.billing_cycles_id_seq OWNED BY public.billing_cycles.id;


--
-- Name: billing_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billing_items (
    id integer NOT NULL,
    begin_date date NOT NULL,
    end_date date NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    contract_type public.billing_items_contract_type,
    billing_id integer NOT NULL,
    begin_reading_id integer,
    end_reading_id integer,
    tariff_id integer,
    register_id integer NOT NULL
);


--
-- Name: billing_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.billing_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: billing_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.billing_items_id_seq OWNED BY public.billing_items.id;


--
-- Name: billings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billings (
    id integer NOT NULL,
    begin_date date NOT NULL,
    end_date date NOT NULL,
    invoice_number character varying(64),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status public.billings_status,
    billing_cycle_id integer,
    contract_id integer NOT NULL
);


--
-- Name: billings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.billings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: billings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.billings_id_seq OWNED BY public.billings.id;


--
-- Name: brokers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.brokers (
    id integer NOT NULL,
    type character varying NOT NULL,
    external_id character varying
);


--
-- Name: brokers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.brokers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brokers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.brokers_id_seq OWNED BY public.brokers.id;


--
-- Name: contract_tax_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contract_tax_data (
    id integer NOT NULL,
    retailer boolean,
    provider_permission boolean,
    subject_to_tax boolean,
    tax_rate integer,
    tax_number character varying(64),
    sales_tax_number character varying(64),
    creditor_identification character varying(64),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    contract_id integer
);


--
-- Name: contract_tax_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contract_tax_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contract_tax_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contract_tax_data_id_seq OWNED BY public.contract_tax_data.id;


--
-- Name: contracts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contracts (
    id integer NOT NULL,
    signing_date date NOT NULL,
    begin_date date,
    termination_date date,
    end_date date,
    contract_number integer,
    contract_number_addition integer,
    forecast_kwh_pa integer,
    original_signing_user character varying,
    mandate_reference character varying,
    confirm_pricing_model boolean,
    power_of_attorney boolean,
    other_contract boolean,
    move_in boolean,
    "authorization" boolean,
    third_party_billing_number character varying,
    third_party_renter_number character varying,
    metering_point_operator_name character varying,
    old_supplier_name character varying,
    old_customer_number character varying,
    old_account_number character varying,
    energy_consumption_before_kwh_pa character varying,
    down_payment_before_cents_per_month character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    renewable_energy_law_taxation public.contracts_renewable_energy_law_taxation,
    type character varying(64) NOT NULL,
    localpool_id integer,
    customer_bank_account_id integer,
    contractor_bank_account_id integer,
    customer_person_id integer,
    customer_organization_id integer,
    contractor_person_id integer,
    contractor_organization_id integer,
    market_location_id integer,
    CONSTRAINT check_contract_contractor CHECK ((NOT ((contractor_person_id IS NOT NULL) AND (contractor_organization_id IS NOT NULL)))),
    CONSTRAINT check_contract_customer CHECK ((NOT ((customer_person_id IS NOT NULL) AND (customer_organization_id IS NOT NULL))))
);


--
-- Name: contracts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contracts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contracts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contracts_id_seq OWNED BY public.contracts.id;


--
-- Name: contracts_tariffs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contracts_tariffs (
    tariff_id integer NOT NULL,
    contract_id integer NOT NULL
);


--
-- Name: core_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_configs (
    id integer NOT NULL,
    namespace character varying NOT NULL,
    key character varying NOT NULL,
    value character varying NOT NULL
);


--
-- Name: core_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.core_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: core_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.core_configs_id_seq OWNED BY public.core_configs.id;


--
-- Name: customer_numbers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_numbers (
    id integer NOT NULL
);


--
-- Name: customer_numbers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customer_numbers_id_seq
    START WITH 100000
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_numbers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customer_numbers_id_seq OWNED BY public.customer_numbers.id;


--
-- Name: devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.devices (
    id integer NOT NULL,
    manufacturer_name character varying,
    manufacturer_product_name character varying,
    manufacturer_product_serialnumber character varying,
    image character varying,
    mode character varying,
    law character varying,
    category character varying,
    shop_link character varying,
    primary_energy character varying,
    watt_peak integer,
    watt_hour_pa integer,
    commissioning date,
    mobile boolean DEFAULT false,
    metering_point_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    register_id integer
);


--
-- Name: devices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.devices_id_seq OWNED BY public.devices.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documents (
    id integer NOT NULL,
    path character varying(128) NOT NULL,
    encryption_details character varying(512) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.documents_id_seq OWNED BY public.documents.id;


--
-- Name: energy_classifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.energy_classifications (
    id integer NOT NULL,
    tariff_name character varying,
    nuclear_ratio double precision NOT NULL,
    coal_ratio double precision NOT NULL,
    gas_ratio double precision NOT NULL,
    other_fossiles_ratio double precision NOT NULL,
    renewables_eeg_ratio double precision NOT NULL,
    other_renewables_ratio double precision NOT NULL,
    co2_emission_gramm_per_kwh double precision NOT NULL,
    nuclear_waste_miligramm_per_kwh double precision NOT NULL,
    end_date date,
    organization_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: energy_classifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.energy_classifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: energy_classifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.energy_classifications_id_seq OWNED BY public.energy_classifications.id;


--
-- Name: formula_parts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.formula_parts (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    operator public.formula_parts_operator,
    register_id integer NOT NULL,
    operand_id integer NOT NULL
);


--
-- Name: formula_parts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.formula_parts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: formula_parts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.formula_parts_id_seq OWNED BY public.formula_parts.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id integer NOT NULL,
    name character varying(64) NOT NULL,
    description character varying(256),
    start_date date,
    show_object boolean,
    show_production boolean,
    show_energy boolean,
    show_contact boolean,
    show_display_app boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    type character varying(64) NOT NULL,
    slug character varying(64) NOT NULL,
    address_id integer,
    owner_person_id integer,
    owner_organization_id integer,
    gap_contract_customer_person_id integer,
    gap_contract_customer_organization_id integer,
    distribution_system_operator_id integer,
    transmission_system_operator_id integer,
    electricity_supplier_id integer,
    bank_account_id integer,
    CONSTRAINT check_localpool_gap_contract_customer CHECK ((NOT ((gap_contract_customer_person_id IS NOT NULL) AND (gap_contract_customer_organization_id IS NOT NULL)))),
    CONSTRAINT check_localpool_owner CHECK ((NOT ((owner_person_id IS NOT NULL) AND (owner_organization_id IS NOT NULL))))
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: market_locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.market_locations (
    id integer NOT NULL,
    name character varying(64) NOT NULL,
    market_location_id character varying(11),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    group_id integer NOT NULL
);


--
-- Name: market_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.market_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: market_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.market_locations_id_seq OWNED BY public.market_locations.id;


--
-- Name: meters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.meters (
    id integer NOT NULL,
    product_serialnumber character varying(128),
    product_name character varying(64),
    manufacturer_description character varying,
    location_description character varying,
    build_year integer,
    sent_data_dso date,
    converter_constant integer,
    calibrated_until date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    datasource public.meters_datasource,
    manufacturer_name public.meters_manufacturer_name,
    ownership public.meters_ownership,
    direction_number public.meters_direction_number,
    edifact_metering_type public.meters_edifact_metering_type,
    edifact_meter_size public.meters_edifact_meter_size,
    edifact_measurement_method public.meters_edifact_measurement_method,
    edifact_tariff public.meters_edifact_tariff,
    edifact_mounting_method public.meters_edifact_mounting_method,
    edifact_voltage_level public.meters_edifact_voltage_level,
    edifact_cycle_interval public.meters_edifact_cycle_interval,
    edifact_data_logging public.meters_edifact_data_logging,
    type character varying NOT NULL,
    sequence_number integer,
    group_id integer,
    broker_id integer,
    legacy_buzznid character varying
);


--
-- Name: meters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.meters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.meters_id_seq OWNED BY public.meters.id;


--
-- Name: organization_market_functions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_market_functions (
    id integer NOT NULL,
    market_partner_id character varying(64) NOT NULL,
    edifact_email character varying(64) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    function public.organization_market_functions_function,
    address_id integer,
    organization_id integer,
    contact_person_id integer
);


--
-- Name: organization_market_functions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organization_market_functions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_market_functions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organization_market_functions_id_seq OWNED BY public.organization_market_functions.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations (
    id integer NOT NULL,
    name character varying(64) NOT NULL,
    description character varying(256),
    email character varying(64),
    phone character varying(64),
    fax character varying(64),
    website character varying(64),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    slug character varying(64) NOT NULL,
    customer_number integer,
    address_id integer,
    legal_representation_id integer,
    contact_id integer
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id integer NOT NULL,
    begin_date date NOT NULL,
    price_cents integer NOT NULL,
    end_date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    cycle public.payments_cycle,
    contract_id integer NOT NULL
);


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- Name: pdf_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pdf_documents (
    id integer NOT NULL,
    json character varying(16384) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    template_id integer NOT NULL,
    document_id integer NOT NULL,
    localpool_id integer,
    contract_id integer,
    billing_id integer,
    CONSTRAINT check_pdf_document_relations CHECK ((((localpool_id IS NOT NULL) AND (contract_id IS NULL) AND (billing_id IS NULL)) OR ((localpool_id IS NULL) AND (contract_id IS NOT NULL) AND (billing_id IS NULL)) OR ((localpool_id IS NULL) AND (contract_id IS NULL) AND (billing_id IS NOT NULL))))
);


--
-- Name: pdf_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pdf_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pdf_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pdf_documents_id_seq OWNED BY public.pdf_documents.id;


--
-- Name: persons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.persons (
    id integer NOT NULL,
    first_name character varying(64) NOT NULL,
    last_name character varying(64) NOT NULL,
    email character varying(64),
    phone character varying(64),
    fax character varying(64),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    prefix public.persons_prefix,
    preferred_language public.persons_preferred_language,
    title public.persons_title,
    image character varying(64),
    customer_number integer,
    address_id integer
);


--
-- Name: persons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.persons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: persons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.persons_id_seq OWNED BY public.persons.id;


--
-- Name: persons_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.persons_roles (
    person_id integer NOT NULL,
    role_id integer NOT NULL
);


--
-- Name: readings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.readings (
    id integer NOT NULL,
    raw_value integer NOT NULL,
    value integer NOT NULL,
    comment character varying(256),
    date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    unit public.readings_unit,
    reason public.readings_reason,
    read_by public.readings_read_by,
    quality public.readings_quality,
    source public.readings_source,
    status public.readings_status,
    register_id integer NOT NULL
);


--
-- Name: readings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.readings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: readings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.readings_id_seq OWNED BY public.readings.id;


--
-- Name: registers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.registers (
    id integer NOT NULL,
    metering_point_id character varying(64),
    observer_enabled boolean,
    observer_min_threshold integer,
    observer_max_threshold integer,
    observer_offline_monitoring boolean,
    share_with_group boolean NOT NULL,
    share_publicly boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    label public.registers_label,
    direction public.registers_direction,
    type character varying NOT NULL,
    last_observed timestamp without time zone,
    meter_id integer NOT NULL,
    market_location_id integer
);


--
-- Name: registers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.registers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: registers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.registers_id_seq OWNED BY public.registers.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    resource_id integer,
    resource_type character varying(32),
    name public.roles_name
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: schema_info; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_info (
    version integer DEFAULT 0 NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: tariffs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tariffs (
    id integer NOT NULL,
    name character varying(64) NOT NULL,
    begin_date date NOT NULL,
    energyprice_cents_per_kwh double precision NOT NULL,
    baseprice_cents_per_month double precision NOT NULL,
    end_date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    group_id integer NOT NULL
);


--
-- Name: tariffs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tariffs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tariffs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tariffs_id_seq OWNED BY public.tariffs.id;


--
-- Name: templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates (
    id integer NOT NULL,
    version integer NOT NULL,
    source character varying(65536) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name public.templates_name
);


--
-- Name: templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.templates_id_seq OWNED BY public.templates.id;


--
-- Name: zip_to_prices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.zip_to_prices (
    id integer NOT NULL,
    zip integer NOT NULL,
    price_euro_year_dt double precision NOT NULL,
    average_price_cents_kwh_dt double precision NOT NULL,
    baseprice_euro_year_dt double precision NOT NULL,
    unitprice_cents_kwh_dt double precision NOT NULL,
    measurement_euro_year_dt double precision NOT NULL,
    baseprice_euro_year_et double precision NOT NULL,
    unitprice_cents_kwh_et double precision NOT NULL,
    measurement_euro_year_et double precision NOT NULL,
    ka double precision NOT NULL,
    state character varying(32) NOT NULL,
    community character varying(64) NOT NULL,
    vdewid bigint NOT NULL,
    dso character varying(128) NOT NULL,
    updated boolean NOT NULL
);


--
-- Name: zip_to_prices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.zip_to_prices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: zip_to_prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.zip_to_prices_id_seq OWNED BY public.zip_to_prices.id;


--
-- Name: account_previous_password_hashes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_previous_password_hashes ALTER COLUMN id SET DEFAULT nextval('public.account_previous_password_hashes_id_seq'::regclass);


--
-- Name: accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts ALTER COLUMN id SET DEFAULT nextval('public.accounts_id_seq'::regclass);


--
-- Name: addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses ALTER COLUMN id SET DEFAULT nextval('public.addresses_id_seq'::regclass);


--
-- Name: bank_accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_accounts ALTER COLUMN id SET DEFAULT nextval('public.bank_accounts_id_seq'::regclass);


--
-- Name: banks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.banks ALTER COLUMN id SET DEFAULT nextval('public.banks_id_seq'::regclass);


--
-- Name: billing_cycles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_cycles ALTER COLUMN id SET DEFAULT nextval('public.billing_cycles_id_seq'::regclass);


--
-- Name: billing_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_items ALTER COLUMN id SET DEFAULT nextval('public.billing_items_id_seq'::regclass);


--
-- Name: billings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billings ALTER COLUMN id SET DEFAULT nextval('public.billings_id_seq'::regclass);


--
-- Name: brokers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brokers ALTER COLUMN id SET DEFAULT nextval('public.brokers_id_seq'::regclass);


--
-- Name: contract_tax_data id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contract_tax_data ALTER COLUMN id SET DEFAULT nextval('public.contract_tax_data_id_seq'::regclass);


--
-- Name: contracts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contracts ALTER COLUMN id SET DEFAULT nextval('public.contracts_id_seq'::regclass);


--
-- Name: core_configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_configs ALTER COLUMN id SET DEFAULT nextval('public.core_configs_id_seq'::regclass);


--
-- Name: customer_numbers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_numbers ALTER COLUMN id SET DEFAULT nextval('public.customer_numbers_id_seq'::regclass);


--
-- Name: devices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devices ALTER COLUMN id SET DEFAULT nextval('public.devices_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents ALTER COLUMN id SET DEFAULT nextval('public.documents_id_seq'::regclass);


--
-- Name: energy_classifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.energy_classifications ALTER COLUMN id SET DEFAULT nextval('public.energy_classifications_id_seq'::regclass);


--
-- Name: formula_parts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.formula_parts ALTER COLUMN id SET DEFAULT nextval('public.formula_parts_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: market_locations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.market_locations ALTER COLUMN id SET DEFAULT nextval('public.market_locations_id_seq'::regclass);


--
-- Name: meters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meters ALTER COLUMN id SET DEFAULT nextval('public.meters_id_seq'::regclass);


--
-- Name: organization_market_functions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_market_functions ALTER COLUMN id SET DEFAULT nextval('public.organization_market_functions_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- Name: pdf_documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pdf_documents ALTER COLUMN id SET DEFAULT nextval('public.pdf_documents_id_seq'::regclass);


--
-- Name: persons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.persons ALTER COLUMN id SET DEFAULT nextval('public.persons_id_seq'::regclass);


--
-- Name: readings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.readings ALTER COLUMN id SET DEFAULT nextval('public.readings_id_seq'::regclass);


--
-- Name: registers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registers ALTER COLUMN id SET DEFAULT nextval('public.registers_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: tariffs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tariffs ALTER COLUMN id SET DEFAULT nextval('public.tariffs_id_seq'::regclass);


--
-- Name: templates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates ALTER COLUMN id SET DEFAULT nextval('public.templates_id_seq'::regclass);


--
-- Name: zip_to_prices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zip_to_prices ALTER COLUMN id SET DEFAULT nextval('public.zip_to_prices_id_seq'::regclass);


--
-- Name: account_login_change_keys account_login_change_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_login_change_keys
    ADD CONSTRAINT account_login_change_keys_pkey PRIMARY KEY (id);


--
-- Name: account_password_change_times account_password_change_times_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_password_change_times
    ADD CONSTRAINT account_password_change_times_pkey PRIMARY KEY (id);


--
-- Name: account_password_hashes account_password_hashes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_password_hashes
    ADD CONSTRAINT account_password_hashes_pkey PRIMARY KEY (id);


--
-- Name: account_password_reset_keys account_password_reset_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_password_reset_keys
    ADD CONSTRAINT account_password_reset_keys_pkey PRIMARY KEY (id);


--
-- Name: account_previous_password_hashes account_previous_password_hashes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_previous_password_hashes
    ADD CONSTRAINT account_previous_password_hashes_pkey PRIMARY KEY (id);


--
-- Name: account_remember_keys account_remember_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_remember_keys
    ADD CONSTRAINT account_remember_keys_pkey PRIMARY KEY (id);


--
-- Name: account_statuses account_statuses_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_statuses
    ADD CONSTRAINT account_statuses_name_key UNIQUE (name);


--
-- Name: account_statuses account_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_statuses
    ADD CONSTRAINT account_statuses_pkey PRIMARY KEY (id);


--
-- Name: account_verification_keys account_verification_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_verification_keys
    ADD CONSTRAINT account_verification_keys_pkey PRIMARY KEY (id);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: bank_accounts bank_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_accounts
    ADD CONSTRAINT bank_accounts_pkey PRIMARY KEY (id);


--
-- Name: banks banks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.banks
    ADD CONSTRAINT banks_pkey PRIMARY KEY (id);


--
-- Name: billing_cycles billing_cycles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_cycles
    ADD CONSTRAINT billing_cycles_pkey PRIMARY KEY (id);


--
-- Name: billing_items billing_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_items
    ADD CONSTRAINT billing_items_pkey PRIMARY KEY (id);


--
-- Name: billings billings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billings
    ADD CONSTRAINT billings_pkey PRIMARY KEY (id);


--
-- Name: brokers brokers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brokers
    ADD CONSTRAINT brokers_pkey PRIMARY KEY (id);


--
-- Name: contract_tax_data contract_tax_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contract_tax_data
    ADD CONSTRAINT contract_tax_data_pkey PRIMARY KEY (id);


--
-- Name: contracts contracts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT contracts_pkey PRIMARY KEY (id);


--
-- Name: core_configs core_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_configs
    ADD CONSTRAINT core_configs_pkey PRIMARY KEY (id);


--
-- Name: customer_numbers customer_numbers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_numbers
    ADD CONSTRAINT customer_numbers_pkey PRIMARY KEY (id);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: energy_classifications energy_classifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.energy_classifications
    ADD CONSTRAINT energy_classifications_pkey PRIMARY KEY (id);


--
-- Name: formula_parts formula_parts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.formula_parts
    ADD CONSTRAINT formula_parts_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: market_locations market_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.market_locations
    ADD CONSTRAINT market_locations_pkey PRIMARY KEY (id);


--
-- Name: meters meters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meters
    ADD CONSTRAINT meters_pkey PRIMARY KEY (id);


--
-- Name: organization_market_functions organization_market_functions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_market_functions
    ADD CONSTRAINT organization_market_functions_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: pdf_documents pdf_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pdf_documents
    ADD CONSTRAINT pdf_documents_pkey PRIMARY KEY (id);


--
-- Name: persons persons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.persons
    ADD CONSTRAINT persons_pkey PRIMARY KEY (id);


--
-- Name: readings readings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.readings
    ADD CONSTRAINT readings_pkey PRIMARY KEY (id);


--
-- Name: registers registers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registers
    ADD CONSTRAINT registers_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: tariffs tariffs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tariffs
    ADD CONSTRAINT tariffs_pkey PRIMARY KEY (id);


--
-- Name: templates templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates
    ADD CONSTRAINT templates_pkey PRIMARY KEY (id);


--
-- Name: zip_to_prices zip_to_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zip_to_prices
    ADD CONSTRAINT zip_to_prices_pkey PRIMARY KEY (id);


--
-- Name: accounts_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX accounts_email_index ON public.accounts USING btree (email) WHERE (status_id = ANY (ARRAY[1, 2]));


--
-- Name: index_bank_accounts_on_owner_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bank_accounts_on_owner_organization_id ON public.bank_accounts USING btree (owner_organization_id);


--
-- Name: index_bank_accounts_on_owner_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bank_accounts_on_owner_person_id ON public.bank_accounts USING btree (owner_person_id);


--
-- Name: index_banks_on_bic; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_banks_on_bic ON public.banks USING btree (bic);


--
-- Name: index_banks_on_blz; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_banks_on_blz ON public.banks USING btree (blz);


--
-- Name: index_billing_cycles_on_localpool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billing_cycles_on_localpool_id ON public.billing_cycles USING btree (localpool_id);


--
-- Name: index_billing_items_on_begin_reading_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billing_items_on_begin_reading_id ON public.billing_items USING btree (begin_reading_id);


--
-- Name: index_billing_items_on_billing_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billing_items_on_billing_id ON public.billing_items USING btree (billing_id);


--
-- Name: index_billing_items_on_end_reading_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billing_items_on_end_reading_id ON public.billing_items USING btree (end_reading_id);


--
-- Name: index_billing_items_on_register_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billing_items_on_register_id ON public.billing_items USING btree (register_id);


--
-- Name: index_billing_items_on_tariff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billing_items_on_tariff_id ON public.billing_items USING btree (tariff_id);


--
-- Name: index_billings_on_billing_cycle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billings_on_billing_cycle_id ON public.billings USING btree (billing_cycle_id);


--
-- Name: index_billings_on_billing_cycle_id_and_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billings_on_billing_cycle_id_and_status ON public.billings USING btree (billing_cycle_id, status);


--
-- Name: index_billings_on_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billings_on_contract_id ON public.billings USING btree (contract_id);


--
-- Name: index_billings_on_invoice_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_billings_on_invoice_number ON public.billings USING btree (invoice_number);


--
-- Name: index_contract_tax_data_on_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contract_tax_data_on_contract_id ON public.contract_tax_data USING btree (contract_id);


--
-- Name: index_contracts_on_contractor_bank_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_contractor_bank_account_id ON public.contracts USING btree (contractor_bank_account_id);


--
-- Name: index_contracts_on_contractor_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_contractor_organization_id ON public.contracts USING btree (contractor_organization_id);


--
-- Name: index_contracts_on_contractor_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_contractor_person_id ON public.contracts USING btree (contractor_person_id);


--
-- Name: index_contracts_on_customer_bank_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_customer_bank_account_id ON public.contracts USING btree (customer_bank_account_id);


--
-- Name: index_contracts_on_customer_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_customer_organization_id ON public.contracts USING btree (customer_organization_id);


--
-- Name: index_contracts_on_customer_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_customer_person_id ON public.contracts USING btree (customer_person_id);


--
-- Name: index_contracts_on_localpool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_localpool_id ON public.contracts USING btree (localpool_id);


--
-- Name: index_contracts_on_market_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_market_location_id ON public.contracts USING btree (market_location_id);


--
-- Name: index_contracts_tariffs_on_contract_id_and_tariff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_contracts_tariffs_on_contract_id_and_tariff_id ON public.contracts_tariffs USING btree (contract_id, tariff_id);


--
-- Name: index_contracts_tariffs_on_tariff_id_and_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_contracts_tariffs_on_tariff_id_and_contract_id ON public.contracts_tariffs USING btree (tariff_id, contract_id);


--
-- Name: index_devices_on_metering_point_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_devices_on_metering_point_id ON public.devices USING btree (metering_point_id);


--
-- Name: index_documents_on_path; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_documents_on_path ON public.documents USING btree (path);


--
-- Name: index_energy_classifications_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_energy_classifications_on_organization_id ON public.energy_classifications USING btree (organization_id);


--
-- Name: index_formula_parts_on_operand_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_formula_parts_on_operand_id ON public.formula_parts USING btree (operand_id);


--
-- Name: index_formula_parts_on_register_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_formula_parts_on_register_id ON public.formula_parts USING btree (register_id);


--
-- Name: index_groups_on_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_address_id ON public.groups USING btree (address_id);


--
-- Name: index_groups_on_bank_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_bank_account_id ON public.groups USING btree (bank_account_id);


--
-- Name: index_groups_on_distribution_system_operator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_distribution_system_operator_id ON public.groups USING btree (distribution_system_operator_id);


--
-- Name: index_groups_on_electricity_supplier_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_electricity_supplier_id ON public.groups USING btree (electricity_supplier_id);


--
-- Name: index_groups_on_gap_contract_customer_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_gap_contract_customer_organization_id ON public.groups USING btree (gap_contract_customer_organization_id);


--
-- Name: index_groups_on_gap_contract_customer_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_gap_contract_customer_person_id ON public.groups USING btree (gap_contract_customer_person_id);


--
-- Name: index_groups_on_owner_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_owner_organization_id ON public.groups USING btree (owner_organization_id);


--
-- Name: index_groups_on_owner_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_owner_person_id ON public.groups USING btree (owner_person_id);


--
-- Name: index_groups_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_groups_on_slug ON public.groups USING btree (slug);


--
-- Name: index_groups_on_transmission_system_operator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_transmission_system_operator_id ON public.groups USING btree (transmission_system_operator_id);


--
-- Name: index_market_functions_on_organization_id_function; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_market_functions_on_organization_id_function ON public.organization_market_functions USING btree (organization_id, function);


--
-- Name: index_market_locations_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_market_locations_on_group_id ON public.market_locations USING btree (group_id);


--
-- Name: index_market_locations_on_market_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_market_locations_on_market_location_id ON public.market_locations USING btree (market_location_id);


--
-- Name: index_meters_on_broker_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meters_on_broker_id ON public.meters USING btree (broker_id);


--
-- Name: index_meters_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meters_on_group_id ON public.meters USING btree (group_id);


--
-- Name: index_meters_on_group_id_and_sequence_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_meters_on_group_id_and_sequence_number ON public.meters USING btree (group_id, sequence_number);


--
-- Name: index_organization_market_functions_on_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_market_functions_on_address_id ON public.organization_market_functions USING btree (address_id);


--
-- Name: index_organization_market_functions_on_contact_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_market_functions_on_contact_person_id ON public.organization_market_functions USING btree (contact_person_id);


--
-- Name: index_organization_market_functions_on_market_partner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organization_market_functions_on_market_partner_id ON public.organization_market_functions USING btree (market_partner_id);


--
-- Name: index_organization_market_functions_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_market_functions_on_organization_id ON public.organization_market_functions USING btree (organization_id);


--
-- Name: index_organizations_on_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_on_address_id ON public.organizations USING btree (address_id);


--
-- Name: index_organizations_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_on_contact_id ON public.organizations USING btree (contact_id);


--
-- Name: index_organizations_on_legal_representation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_on_legal_representation_id ON public.organizations USING btree (legal_representation_id);


--
-- Name: index_organizations_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organizations_on_slug ON public.organizations USING btree (slug);


--
-- Name: index_payments_on_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payments_on_contract_id ON public.payments USING btree (contract_id);


--
-- Name: index_pdf_documents_on_billing_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pdf_documents_on_billing_id ON public.pdf_documents USING btree (billing_id);


--
-- Name: index_pdf_documents_on_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pdf_documents_on_contract_id ON public.pdf_documents USING btree (contract_id);


--
-- Name: index_pdf_documents_on_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pdf_documents_on_document_id ON public.pdf_documents USING btree (document_id);


--
-- Name: index_pdf_documents_on_localpool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pdf_documents_on_localpool_id ON public.pdf_documents USING btree (localpool_id);


--
-- Name: index_pdf_documents_on_template_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pdf_documents_on_template_id ON public.pdf_documents USING btree (template_id);


--
-- Name: index_persons_on_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_persons_on_address_id ON public.persons USING btree (address_id);


--
-- Name: index_persons_on_first_name_and_last_name_and_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_persons_on_first_name_and_last_name_and_email ON public.persons USING btree (first_name, last_name, email);


--
-- Name: index_persons_roles_on_person_id_and_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_persons_roles_on_person_id_and_role_id ON public.persons_roles USING btree (person_id, role_id);


--
-- Name: index_persons_roles_on_role_id_and_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_persons_roles_on_role_id_and_person_id ON public.persons_roles USING btree (role_id, person_id);


--
-- Name: index_readings_on_register_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_readings_on_register_id ON public.readings USING btree (register_id);


--
-- Name: index_readings_on_register_id_and_date_and_reason; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_readings_on_register_id_and_date_and_reason ON public.readings USING btree (register_id, date, reason);


--
-- Name: index_registers_on_market_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_registers_on_market_location_id ON public.registers USING btree (market_location_id);


--
-- Name: index_registers_on_meter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_registers_on_meter_id ON public.registers USING btree (meter_id);


--
-- Name: index_registers_on_meter_id_and_direction; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_registers_on_meter_id_and_direction ON public.registers USING btree (meter_id, direction);


--
-- Name: index_tariffs_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tariffs_on_group_id ON public.tariffs USING btree (group_id);


--
-- Name: index_zip_to_prices_on_zip; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_zip_to_prices_on_zip ON public.zip_to_prices USING btree (zip);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: account_login_change_keys account_login_change_keys_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_login_change_keys
    ADD CONSTRAINT account_login_change_keys_id_fkey FOREIGN KEY (id) REFERENCES public.accounts(id);


--
-- Name: account_password_change_times account_password_change_times_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_password_change_times
    ADD CONSTRAINT account_password_change_times_id_fkey FOREIGN KEY (id) REFERENCES public.accounts(id);


--
-- Name: account_password_hashes account_password_hashes_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_password_hashes
    ADD CONSTRAINT account_password_hashes_id_fkey FOREIGN KEY (id) REFERENCES public.accounts(id);


--
-- Name: account_password_reset_keys account_password_reset_keys_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_password_reset_keys
    ADD CONSTRAINT account_password_reset_keys_id_fkey FOREIGN KEY (id) REFERENCES public.accounts(id);


--
-- Name: account_previous_password_hashes account_previous_password_hashes_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_previous_password_hashes
    ADD CONSTRAINT account_previous_password_hashes_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: account_remember_keys account_remember_keys_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_remember_keys
    ADD CONSTRAINT account_remember_keys_id_fkey FOREIGN KEY (id) REFERENCES public.accounts(id);


--
-- Name: account_verification_keys account_verification_keys_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_verification_keys
    ADD CONSTRAINT account_verification_keys_id_fkey FOREIGN KEY (id) REFERENCES public.accounts(id);


--
-- Name: accounts accounts_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.persons(id);


--
-- Name: accounts accounts_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.account_statuses(id);


--
-- Name: bank_accounts fk_bank_accounts_organization; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_accounts
    ADD CONSTRAINT fk_bank_accounts_organization FOREIGN KEY (owner_organization_id) REFERENCES public.organizations(id);


--
-- Name: bank_accounts fk_bank_accounts_person; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_accounts
    ADD CONSTRAINT fk_bank_accounts_person FOREIGN KEY (owner_person_id) REFERENCES public.persons(id);


--
-- Name: billing_cycles fk_billing_cycles_localpool; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_cycles
    ADD CONSTRAINT fk_billing_cycles_localpool FOREIGN KEY (localpool_id) REFERENCES public.groups(id);


--
-- Name: billing_items fk_billing_items_billing; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_items
    ADD CONSTRAINT fk_billing_items_billing FOREIGN KEY (billing_id) REFERENCES public.billings(id);


--
-- Name: billing_items fk_billing_items_register; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_items
    ADD CONSTRAINT fk_billing_items_register FOREIGN KEY (register_id) REFERENCES public.registers(id);


--
-- Name: billings fk_billings_billing_cycles; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billings
    ADD CONSTRAINT fk_billings_billing_cycles FOREIGN KEY (billing_cycle_id) REFERENCES public.billing_cycles(id);


--
-- Name: billings fk_billings_contracts; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billings
    ADD CONSTRAINT fk_billings_contracts FOREIGN KEY (contract_id) REFERENCES public.contracts(id);


--
-- Name: contracts fk_contracts_contractor_bank_account; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT fk_contracts_contractor_bank_account FOREIGN KEY (contractor_bank_account_id) REFERENCES public.bank_accounts(id);


--
-- Name: contracts fk_contracts_contractor_organization; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT fk_contracts_contractor_organization FOREIGN KEY (contractor_organization_id) REFERENCES public.organizations(id);


--
-- Name: contracts fk_contracts_contractor_person; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT fk_contracts_contractor_person FOREIGN KEY (contractor_person_id) REFERENCES public.persons(id);


--
-- Name: contracts fk_contracts_customer_bank_account; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT fk_contracts_customer_bank_account FOREIGN KEY (customer_bank_account_id) REFERENCES public.bank_accounts(id);


--
-- Name: contracts fk_contracts_customer_organization; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT fk_contracts_customer_organization FOREIGN KEY (customer_organization_id) REFERENCES public.organizations(id);


--
-- Name: contracts fk_contracts_customer_person; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT fk_contracts_customer_person FOREIGN KEY (customer_person_id) REFERENCES public.persons(id);


--
-- Name: contracts fk_contracts_localpool; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT fk_contracts_localpool FOREIGN KEY (localpool_id) REFERENCES public.groups(id);


--
-- Name: contracts fk_contracts_market_location; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT fk_contracts_market_location FOREIGN KEY (market_location_id) REFERENCES public.market_locations(id);


--
-- Name: contracts_tariffs fk_contracts_tariffs_contract; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contracts_tariffs
    ADD CONSTRAINT fk_contracts_tariffs_contract FOREIGN KEY (contract_id) REFERENCES public.contracts(id);


--
-- Name: contracts_tariffs fk_contracts_tariffs_tariff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contracts_tariffs
    ADD CONSTRAINT fk_contracts_tariffs_tariff FOREIGN KEY (tariff_id) REFERENCES public.tariffs(id);


--
-- Name: formula_parts fk_formula_parts_operand; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.formula_parts
    ADD CONSTRAINT fk_formula_parts_operand FOREIGN KEY (operand_id) REFERENCES public.registers(id);


--
-- Name: formula_parts fk_formula_parts_register; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.formula_parts
    ADD CONSTRAINT fk_formula_parts_register FOREIGN KEY (register_id) REFERENCES public.registers(id);


--
-- Name: groups fk_groups_address; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_groups_address FOREIGN KEY (address_id) REFERENCES public.addresses(id);


--
-- Name: groups fk_groups_distribution_system_operator; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_groups_distribution_system_operator FOREIGN KEY (distribution_system_operator_id) REFERENCES public.organizations(id);


--
-- Name: groups fk_groups_electricity_supplier; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_groups_electricity_supplier FOREIGN KEY (electricity_supplier_id) REFERENCES public.organizations(id);


--
-- Name: groups fk_groups_gap_contract_customer_organization; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_groups_gap_contract_customer_organization FOREIGN KEY (gap_contract_customer_organization_id) REFERENCES public.organizations(id);


--
-- Name: groups fk_groups_gap_contract_customer_person; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_groups_gap_contract_customer_person FOREIGN KEY (gap_contract_customer_person_id) REFERENCES public.persons(id);


--
-- Name: groups fk_groups_owner_organization; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_groups_owner_organization FOREIGN KEY (owner_organization_id) REFERENCES public.organizations(id);


--
-- Name: groups fk_groups_owner_person; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_groups_owner_person FOREIGN KEY (owner_person_id) REFERENCES public.persons(id);


--
-- Name: groups fk_groups_transmission_system_operator; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_groups_transmission_system_operator FOREIGN KEY (transmission_system_operator_id) REFERENCES public.organizations(id);


--
-- Name: market_locations fk_market_locations_group; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.market_locations
    ADD CONSTRAINT fk_market_locations_group FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: meters fk_meters_broker; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meters
    ADD CONSTRAINT fk_meters_broker FOREIGN KEY (broker_id) REFERENCES public.brokers(id);


--
-- Name: meters fk_meters_group; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meters
    ADD CONSTRAINT fk_meters_group FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: organization_market_functions fk_organization_market_functions_address; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_market_functions
    ADD CONSTRAINT fk_organization_market_functions_address FOREIGN KEY (address_id) REFERENCES public.addresses(id);


--
-- Name: organization_market_functions fk_organization_market_functions_contact_person; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_market_functions
    ADD CONSTRAINT fk_organization_market_functions_contact_person FOREIGN KEY (contact_person_id) REFERENCES public.persons(id);


--
-- Name: organization_market_functions fk_organization_market_functions_organization; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_market_functions
    ADD CONSTRAINT fk_organization_market_functions_organization FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: persons fk_organizations_address; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.persons
    ADD CONSTRAINT fk_organizations_address FOREIGN KEY (address_id) REFERENCES public.addresses(id);


--
-- Name: organizations fk_organizations_address; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT fk_organizations_address FOREIGN KEY (address_id) REFERENCES public.addresses(id);


--
-- Name: organizations fk_organizations_contact; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT fk_organizations_contact FOREIGN KEY (contact_id) REFERENCES public.persons(id);


--
-- Name: organizations fk_organizations_customer_number; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT fk_organizations_customer_number FOREIGN KEY (customer_number) REFERENCES public.customer_numbers(id);


--
-- Name: organizations fk_organizations_legal_representation; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT fk_organizations_legal_representation FOREIGN KEY (legal_representation_id) REFERENCES public.persons(id);


--
-- Name: payments fk_payments_contract; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT fk_payments_contract FOREIGN KEY (contract_id) REFERENCES public.contracts(id) ON DELETE CASCADE;


--
-- Name: pdf_documents fk_pdf_documents_billing; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pdf_documents
    ADD CONSTRAINT fk_pdf_documents_billing FOREIGN KEY (billing_id) REFERENCES public.billings(id);


--
-- Name: pdf_documents fk_pdf_documents_contract; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pdf_documents
    ADD CONSTRAINT fk_pdf_documents_contract FOREIGN KEY (contract_id) REFERENCES public.contracts(id);


--
-- Name: pdf_documents fk_pdf_documents_document; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pdf_documents
    ADD CONSTRAINT fk_pdf_documents_document FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: pdf_documents fk_pdf_documents_localpool; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pdf_documents
    ADD CONSTRAINT fk_pdf_documents_localpool FOREIGN KEY (localpool_id) REFERENCES public.groups(id);


--
-- Name: pdf_documents fk_pdf_documents_template; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pdf_documents
    ADD CONSTRAINT fk_pdf_documents_template FOREIGN KEY (template_id) REFERENCES public.templates(id);


--
-- Name: persons fk_persons_customer_number; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.persons
    ADD CONSTRAINT fk_persons_customer_number FOREIGN KEY (customer_number) REFERENCES public.customer_numbers(id);


--
-- Name: readings fk_readings_register; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.readings
    ADD CONSTRAINT fk_readings_register FOREIGN KEY (register_id) REFERENCES public.registers(id);


--
-- Name: registers fk_registers_market_location; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registers
    ADD CONSTRAINT fk_registers_market_location FOREIGN KEY (market_location_id) REFERENCES public.market_locations(id);


--
-- Name: registers fk_registers_meter; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registers
    ADD CONSTRAINT fk_registers_meter FOREIGN KEY (meter_id) REFERENCES public.meters(id);


--
-- Name: tariffs fk_tariffs_group; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tariffs
    ADD CONSTRAINT fk_tariffs_group FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: contract_tax_data fk_tax_data_contract; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contract_tax_data
    ADD CONSTRAINT fk_tax_data_contract FOREIGN KEY (contract_id) REFERENCES public.contracts(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('16');

INSERT INTO schema_migrations (version) VALUES ('17');

INSERT INTO schema_migrations (version) VALUES ('18');

INSERT INTO schema_migrations (version) VALUES ('19');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('20');

INSERT INTO schema_migrations (version) VALUES ('21');

INSERT INTO schema_migrations (version) VALUES ('22');

INSERT INTO schema_migrations (version) VALUES ('23');

INSERT INTO schema_migrations (version) VALUES ('24');

INSERT INTO schema_migrations (version) VALUES ('25');

INSERT INTO schema_migrations (version) VALUES ('26');

INSERT INTO schema_migrations (version) VALUES ('27');

INSERT INTO schema_migrations (version) VALUES ('28');

INSERT INTO schema_migrations (version) VALUES ('29');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('30');

INSERT INTO schema_migrations (version) VALUES ('31');

INSERT INTO schema_migrations (version) VALUES ('32');

INSERT INTO schema_migrations (version) VALUES ('33');

INSERT INTO schema_migrations (version) VALUES ('34');

INSERT INTO schema_migrations (version) VALUES ('35');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('9');

