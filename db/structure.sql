--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.6
-- Dumped by pg_dump version 9.6.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
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


--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

--
-- Name: addresses_country; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE addresses_country AS ENUM (
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
-- Name: billings_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE billings_status AS ENUM (
    'open',
    'calculated',
    'delivered',
    'settled',
    'closed'
);


--
-- Name: contracts_renewable_energy_law_taxation; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE contracts_renewable_energy_law_taxation AS ENUM (
    'F',
    'R'
);


--
-- Name: formula_parts_operator; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE formula_parts_operator AS ENUM (
    '+',
    '-'
);


--
-- Name: meters_direction_number; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE meters_direction_number AS ENUM (
    'ERZ',
    'ZRZ'
);


--
-- Name: meters_edifact_cycle_interval; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE meters_edifact_cycle_interval AS ENUM (
    'MONTHLY',
    'QUARTERLY',
    'HALF_YEARLY',
    'YEARLY'
);


--
-- Name: meters_edifact_data_logging; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE meters_edifact_data_logging AS ENUM (
    'Z04',
    'Z05'
);


--
-- Name: meters_edifact_measurement_method; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE meters_edifact_measurement_method AS ENUM (
    'AMR',
    'MMR'
);


--
-- Name: meters_edifact_meter_size; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE meters_edifact_meter_size AS ENUM (
    'Z01',
    'Z02',
    'Z03'
);


--
-- Name: meters_edifact_metering_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE meters_edifact_metering_type AS ENUM (
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

CREATE TYPE meters_edifact_mounting_method AS ENUM (
    'BKE',
    'DPA',
    'HS'
);


--
-- Name: meters_edifact_tariff; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE meters_edifact_tariff AS ENUM (
    'ETZ',
    'ZTZ',
    'NTZ'
);


--
-- Name: meters_edifact_voltage_level; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE meters_edifact_voltage_level AS ENUM (
    'E06',
    'E05',
    'E04',
    'E03'
);


--
-- Name: meters_manufacturer_name; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE meters_manufacturer_name AS ENUM (
    'easy_meter',
    'other'
);


--
-- Name: meters_ownership; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE meters_ownership AS ENUM (
    'BUZZN',
    'FOREIGN_OWNERSHIP',
    'CUSTOMER',
    'LEASED',
    'BOUGHT'
);


--
-- Name: organization_market_functions_function; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE organization_market_functions_function AS ENUM (
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

CREATE TYPE payments_cycle AS ENUM (
    'monthly',
    'yearly',
    'once'
);


--
-- Name: persons_preferred_language; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE persons_preferred_language AS ENUM (
    'de',
    'en'
);


--
-- Name: persons_prefix; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE persons_prefix AS ENUM (
    'F',
    'M'
);


--
-- Name: persons_title; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE persons_title AS ENUM (
    'Prof.',
    'Dr.',
    'Prof. Dr.'
);


--
-- Name: readings_quality; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE readings_quality AS ENUM (
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

CREATE TYPE readings_read_by AS ENUM (
    'BN',
    'SN',
    'SG',
    'VNB'
);


--
-- Name: readings_reason; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE readings_reason AS ENUM (
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

CREATE TYPE readings_source AS ENUM (
    'SM',
    'MAN'
);


--
-- Name: readings_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE readings_status AS ENUM (
    'Z83',
    'Z84',
    'Z86'
);


--
-- Name: readings_unit; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE readings_unit AS ENUM (
    'Wh',
    'W',
    'm³'
);


--
-- Name: registers_direction; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE registers_direction AS ENUM (
    'in',
    'out'
);


--
-- Name: registers_label; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE registers_label AS ENUM (
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

CREATE TYPE roles_name AS ENUM (
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
-- Name: rodauth_get_previous_salt(bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rodauth_get_previous_salt(acct_id bigint) RETURNS text
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

CREATE FUNCTION rodauth_get_salt(acct_id bigint) RETURNS text
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

CREATE FUNCTION rodauth_previous_password_hash_match(acct_id bigint, hash text) RETURNS boolean
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

CREATE FUNCTION rodauth_valid_password_hash(acct_id bigint, hash text) RETURNS boolean
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

CREATE TABLE account_login_change_keys (
    id bigint NOT NULL,
    key text NOT NULL,
    login text NOT NULL,
    deadline timestamp without time zone DEFAULT ((now())::timestamp without time zone + '1 day'::interval) NOT NULL
);


--
-- Name: account_password_change_times; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE account_password_change_times (
    id bigint NOT NULL,
    changed_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: account_password_hashes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE account_password_hashes (
    id bigint NOT NULL,
    password_hash text NOT NULL
);


--
-- Name: account_password_reset_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE account_password_reset_keys (
    id bigint NOT NULL,
    key text NOT NULL,
    deadline timestamp without time zone DEFAULT ((now())::timestamp without time zone + '1 day'::interval) NOT NULL
);


--
-- Name: account_previous_password_hashes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE account_previous_password_hashes (
    id bigint NOT NULL,
    account_id bigint,
    password_hash text NOT NULL
);


--
-- Name: account_previous_password_hashes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE account_previous_password_hashes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_previous_password_hashes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE account_previous_password_hashes_id_seq OWNED BY account_previous_password_hashes.id;


--
-- Name: account_remember_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE account_remember_keys (
    id bigint NOT NULL,
    key text NOT NULL,
    deadline timestamp without time zone DEFAULT ((now())::timestamp without time zone + '14 days'::interval) NOT NULL
);


--
-- Name: account_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE account_statuses (
    id integer NOT NULL,
    name text NOT NULL
);


--
-- Name: account_verification_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE account_verification_keys (
    id bigint NOT NULL,
    key text NOT NULL,
    requested_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE accounts (
    id bigint NOT NULL,
    status_id integer DEFAULT 1 NOT NULL,
    email citext NOT NULL,
    person_id uuid NOT NULL,
    CONSTRAINT valid_email CHECK ((email ~ '^[^,;@ \r\n]+@[^,@; \r\n]+\.[^,@; \r\n]+$'::citext))
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE accounts_id_seq OWNED BY accounts.id;


--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE addresses (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    street character varying(64) NOT NULL,
    zip character varying(16) NOT NULL,
    city character varying(64) NOT NULL,
    addition character varying(64),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    country addresses_country
);


--
-- Name: bank_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE bank_accounts (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    holder character varying(64) NOT NULL,
    iban character varying(32) NOT NULL,
    bank_name character varying(64),
    bic character varying(16),
    direct_debit boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    owner_person_id uuid,
    owner_organization_id uuid,
    CONSTRAINT check_bank_account_owner CHECK (((NOT ((owner_person_id IS NOT NULL) AND (owner_organization_id IS NOT NULL))) OR ((owner_person_id IS NULL) AND (owner_organization_id IS NULL))))
);


--
-- Name: banks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE banks (
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

CREATE SEQUENCE banks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: banks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE banks_id_seq OWNED BY banks.id;


--
-- Name: billing_cycles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE billing_cycles (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(64) NOT NULL,
    begin_date date NOT NULL,
    end_date date NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    localpool_id uuid NOT NULL
);


--
-- Name: billings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE billings (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    total_energy_consumption_kwh integer NOT NULL,
    total_price_cents integer NOT NULL,
    prepayments_cents integer NOT NULL,
    receivables_cents integer NOT NULL,
    invoice_number character varying(64),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status billings_status,
    start_reading_id uuid,
    end_reading_id uuid,
    device_change_reading_1_id uuid,
    device_change_reading_2_id uuid,
    billing_cycle_id uuid,
    localpool_power_taker_contract_id uuid NOT NULL
);


--
-- Name: brokers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE brokers (
    id integer NOT NULL,
    type character varying NOT NULL,
    external_id character varying
);


--
-- Name: brokers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE brokers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brokers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE brokers_id_seq OWNED BY brokers.id;


--
-- Name: contract_tax_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE contract_tax_data (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    retailer boolean,
    provider_permission boolean,
    subject_to_tax boolean,
    tax_rate integer,
    tax_number character varying(64),
    sales_tax_number character varying(64),
    creditor_identification character varying(64),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    contract_id uuid
);


--
-- Name: contracts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE contracts (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
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
    renewable_energy_law_taxation contracts_renewable_energy_law_taxation,
    type character varying(64) NOT NULL,
    register_id uuid,
    localpool_id uuid,
    customer_bank_account_id uuid,
    contractor_bank_account_id uuid,
    customer_person_id uuid,
    customer_organization_id uuid,
    contractor_person_id uuid,
    contractor_organization_id uuid,
    CONSTRAINT check_contract_contractor CHECK ((NOT ((contractor_person_id IS NOT NULL) AND (contractor_organization_id IS NOT NULL)))),
    CONSTRAINT check_contract_customer CHECK ((NOT ((customer_person_id IS NOT NULL) AND (customer_organization_id IS NOT NULL))))
);


--
-- Name: contracts_tariffs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE contracts_tariffs (
    tariff_id uuid NOT NULL,
    contract_id uuid NOT NULL
);


--
-- Name: core_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE core_configs (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    namespace character varying NOT NULL,
    key character varying NOT NULL,
    value character varying NOT NULL
);


--
-- Name: customer_numbers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE customer_numbers (
    id integer NOT NULL
);


--
-- Name: customer_numbers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE customer_numbers_id_seq
    START WITH 100000
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_numbers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE customer_numbers_id_seq OWNED BY customer_numbers.id;


--
-- Name: devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE devices (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
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
    metering_point_id uuid,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    register_id uuid
);


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE documents (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    path character varying(128) NOT NULL,
    encryption_details character varying(512) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: energy_classifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE energy_classifications (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
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
    organization_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: formula_parts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE formula_parts (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    operator formula_parts_operator,
    register_id uuid NOT NULL,
    operand_id uuid NOT NULL
);


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE groups (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
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
    address_id uuid,
    owner_person_id uuid,
    owner_organization_id uuid,
    distribution_system_operator_id uuid,
    transmission_system_operator_id uuid,
    electricity_supplier_id uuid,
    bank_account_id uuid,
    CONSTRAINT check_localpool_owner CHECK ((NOT ((owner_person_id IS NOT NULL) AND (owner_organization_id IS NOT NULL))))
);


--
-- Name: meters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE meters (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    product_name character varying(64),
    product_serialnumber character varying(128),
    manufacturer_description character varying,
    location_description character varying,
    build_year integer,
    sent_data_dso date,
    converter_constant integer,
    calibrated_until date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    manufacturer_name meters_manufacturer_name,
    ownership meters_ownership,
    direction_number meters_direction_number,
    edifact_metering_type meters_edifact_metering_type,
    edifact_meter_size meters_edifact_meter_size,
    edifact_measurement_method meters_edifact_measurement_method,
    edifact_tariff meters_edifact_tariff,
    edifact_mounting_method meters_edifact_mounting_method,
    edifact_voltage_level meters_edifact_voltage_level,
    edifact_cycle_interval meters_edifact_cycle_interval,
    edifact_data_logging meters_edifact_data_logging,
    type character varying NOT NULL,
    sequence_number integer,
    group_id uuid,
    broker_id integer,
    legacy_buzznid character varying
);


--
-- Name: organization_market_functions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE organization_market_functions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    market_partner_id character varying(64) NOT NULL,
    edifact_email character varying(64) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    function organization_market_functions_function,
    address_id uuid,
    organization_id uuid,
    contact_person_id uuid
);


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE organizations (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
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
    address_id uuid,
    legal_representation_id uuid,
    contact_id uuid
);


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE payments (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    begin_date date NOT NULL,
    price_cents integer NOT NULL,
    end_date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    cycle payments_cycle,
    contract_id uuid NOT NULL
);


--
-- Name: persons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE persons (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    first_name character varying(64) NOT NULL,
    last_name character varying(64) NOT NULL,
    email character varying(64) NOT NULL,
    phone character varying(64),
    fax character varying(64),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    prefix persons_prefix,
    preferred_language persons_preferred_language,
    title persons_title,
    image character varying(64),
    customer_number integer,
    address_id uuid
);


--
-- Name: persons_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE persons_roles (
    person_id uuid NOT NULL,
    role_id integer NOT NULL
);


--
-- Name: readings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE readings (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    raw_value double precision NOT NULL,
    value double precision NOT NULL,
    comment character varying(256),
    date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    unit readings_unit,
    reason readings_reason,
    read_by readings_read_by,
    quality readings_quality,
    source readings_source,
    status readings_status,
    register_id uuid NOT NULL
);


--
-- Name: registers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE registers (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    metering_point_id character varying(64),
    observer_enabled boolean,
    observer_min_threshold integer,
    observer_max_threshold integer,
    observer_offline_monitoring boolean,
    name character varying(64) NOT NULL,
    share_with_group boolean NOT NULL,
    share_publicly boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    label registers_label,
    direction registers_direction,
    type character varying NOT NULL,
    last_observed timestamp without time zone,
    meter_id uuid NOT NULL
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE roles (
    id integer NOT NULL,
    resource_id uuid,
    resource_type character varying(32),
    name roles_name
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: schema_info; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_info (
    version integer DEFAULT 0 NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: scores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE scores (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    mode character varying,
    "interval" character varying,
    interval_beginning timestamp without time zone,
    interval_end timestamp without time zone,
    value double precision,
    scoreable_id uuid,
    scoreable_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: tariffs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tariffs (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(64) NOT NULL,
    begin_date date NOT NULL,
    energyprice_cents_per_kwh double precision NOT NULL,
    baseprice_cents_per_month integer NOT NULL,
    end_date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    group_id uuid NOT NULL
);


--
-- Name: zip_to_prices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE zip_to_prices (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
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
-- Name: account_previous_password_hashes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_previous_password_hashes ALTER COLUMN id SET DEFAULT nextval('account_previous_password_hashes_id_seq'::regclass);


--
-- Name: accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts ALTER COLUMN id SET DEFAULT nextval('accounts_id_seq'::regclass);


--
-- Name: banks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY banks ALTER COLUMN id SET DEFAULT nextval('banks_id_seq'::regclass);


--
-- Name: brokers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY brokers ALTER COLUMN id SET DEFAULT nextval('brokers_id_seq'::regclass);


--
-- Name: customer_numbers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY customer_numbers ALTER COLUMN id SET DEFAULT nextval('customer_numbers_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: account_login_change_keys account_login_change_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_login_change_keys
    ADD CONSTRAINT account_login_change_keys_pkey PRIMARY KEY (id);


--
-- Name: account_password_change_times account_password_change_times_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_password_change_times
    ADD CONSTRAINT account_password_change_times_pkey PRIMARY KEY (id);


--
-- Name: account_password_hashes account_password_hashes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_password_hashes
    ADD CONSTRAINT account_password_hashes_pkey PRIMARY KEY (id);


--
-- Name: account_password_reset_keys account_password_reset_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_password_reset_keys
    ADD CONSTRAINT account_password_reset_keys_pkey PRIMARY KEY (id);


--
-- Name: account_previous_password_hashes account_previous_password_hashes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_previous_password_hashes
    ADD CONSTRAINT account_previous_password_hashes_pkey PRIMARY KEY (id);


--
-- Name: account_remember_keys account_remember_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_remember_keys
    ADD CONSTRAINT account_remember_keys_pkey PRIMARY KEY (id);


--
-- Name: account_statuses account_statuses_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_statuses
    ADD CONSTRAINT account_statuses_name_key UNIQUE (name);


--
-- Name: account_statuses account_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_statuses
    ADD CONSTRAINT account_statuses_pkey PRIMARY KEY (id);


--
-- Name: account_verification_keys account_verification_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_verification_keys
    ADD CONSTRAINT account_verification_keys_pkey PRIMARY KEY (id);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: bank_accounts bank_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bank_accounts
    ADD CONSTRAINT bank_accounts_pkey PRIMARY KEY (id);


--
-- Name: banks banks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY banks
    ADD CONSTRAINT banks_pkey PRIMARY KEY (id);


--
-- Name: billing_cycles billing_cycles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY billing_cycles
    ADD CONSTRAINT billing_cycles_pkey PRIMARY KEY (id);


--
-- Name: billings billings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY billings
    ADD CONSTRAINT billings_pkey PRIMARY KEY (id);


--
-- Name: brokers brokers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY brokers
    ADD CONSTRAINT brokers_pkey PRIMARY KEY (id);


--
-- Name: contract_tax_data contract_tax_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contract_tax_data
    ADD CONSTRAINT contract_tax_data_pkey PRIMARY KEY (id);


--
-- Name: contracts contracts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contracts
    ADD CONSTRAINT contracts_pkey PRIMARY KEY (id);


--
-- Name: core_configs core_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY core_configs
    ADD CONSTRAINT core_configs_pkey PRIMARY KEY (id);


--
-- Name: customer_numbers customer_numbers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY customer_numbers
    ADD CONSTRAINT customer_numbers_pkey PRIMARY KEY (id);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: energy_classifications energy_classifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY energy_classifications
    ADD CONSTRAINT energy_classifications_pkey PRIMARY KEY (id);


--
-- Name: formula_parts formula_parts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY formula_parts
    ADD CONSTRAINT formula_parts_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: meters meters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meters
    ADD CONSTRAINT meters_pkey PRIMARY KEY (id);


--
-- Name: organization_market_functions organization_market_functions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organization_market_functions
    ADD CONSTRAINT organization_market_functions_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: persons persons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY persons
    ADD CONSTRAINT persons_pkey PRIMARY KEY (id);


--
-- Name: readings readings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY readings
    ADD CONSTRAINT readings_pkey PRIMARY KEY (id);


--
-- Name: registers registers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY registers
    ADD CONSTRAINT registers_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: scores scores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY scores
    ADD CONSTRAINT scores_pkey PRIMARY KEY (id);


--
-- Name: tariffs tariffs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tariffs
    ADD CONSTRAINT tariffs_pkey PRIMARY KEY (id);


--
-- Name: zip_to_prices zip_to_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY zip_to_prices
    ADD CONSTRAINT zip_to_prices_pkey PRIMARY KEY (id);


--
-- Name: accounts_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX accounts_email_index ON accounts USING btree (email) WHERE (status_id = ANY (ARRAY[1, 2]));


--
-- Name: index_bank_accounts_on_owner_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bank_accounts_on_owner_organization_id ON bank_accounts USING btree (owner_organization_id);


--
-- Name: index_bank_accounts_on_owner_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bank_accounts_on_owner_person_id ON bank_accounts USING btree (owner_person_id);


--
-- Name: index_banks_on_bic; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_banks_on_bic ON banks USING btree (bic);


--
-- Name: index_banks_on_blz; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_banks_on_blz ON banks USING btree (blz);


--
-- Name: index_billing_cycles_on_localpool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billing_cycles_on_localpool_id ON billing_cycles USING btree (localpool_id);


--
-- Name: index_billings_on_billing_cycle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billings_on_billing_cycle_id ON billings USING btree (billing_cycle_id);


--
-- Name: index_billings_on_billing_cycle_id_and_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billings_on_billing_cycle_id_and_status ON billings USING btree (billing_cycle_id, status);


--
-- Name: index_billings_on_localpool_power_taker_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billings_on_localpool_power_taker_contract_id ON billings USING btree (localpool_power_taker_contract_id);


--
-- Name: index_contract_tax_data_on_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contract_tax_data_on_contract_id ON contract_tax_data USING btree (contract_id);


--
-- Name: index_contracts_on_contractor_bank_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_contractor_bank_account_id ON contracts USING btree (contractor_bank_account_id);


--
-- Name: index_contracts_on_contractor_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_contractor_organization_id ON contracts USING btree (contractor_organization_id);


--
-- Name: index_contracts_on_contractor_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_contractor_person_id ON contracts USING btree (contractor_person_id);


--
-- Name: index_contracts_on_customer_bank_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_customer_bank_account_id ON contracts USING btree (customer_bank_account_id);


--
-- Name: index_contracts_on_customer_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_customer_organization_id ON contracts USING btree (customer_organization_id);


--
-- Name: index_contracts_on_customer_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_customer_person_id ON contracts USING btree (customer_person_id);


--
-- Name: index_contracts_on_localpool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_localpool_id ON contracts USING btree (localpool_id);


--
-- Name: index_contracts_on_register_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_register_id ON contracts USING btree (register_id);


--
-- Name: index_contracts_tariffs_on_contract_id_and_tariff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_contracts_tariffs_on_contract_id_and_tariff_id ON contracts_tariffs USING btree (contract_id, tariff_id);


--
-- Name: index_contracts_tariffs_on_tariff_id_and_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_contracts_tariffs_on_tariff_id_and_contract_id ON contracts_tariffs USING btree (tariff_id, contract_id);


--
-- Name: index_devices_on_metering_point_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_devices_on_metering_point_id ON devices USING btree (metering_point_id);


--
-- Name: index_documents_on_path; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_documents_on_path ON documents USING btree (path);


--
-- Name: index_energy_classifications_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_energy_classifications_on_organization_id ON energy_classifications USING btree (organization_id);


--
-- Name: index_formula_parts_on_operand_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_formula_parts_on_operand_id ON formula_parts USING btree (operand_id);


--
-- Name: index_formula_parts_on_register_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_formula_parts_on_register_id ON formula_parts USING btree (register_id);


--
-- Name: index_groups_on_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_address_id ON groups USING btree (address_id);


--
-- Name: index_groups_on_bank_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_bank_account_id ON groups USING btree (bank_account_id);


--
-- Name: index_groups_on_distribution_system_operator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_distribution_system_operator_id ON groups USING btree (distribution_system_operator_id);


--
-- Name: index_groups_on_electricity_supplier_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_electricity_supplier_id ON groups USING btree (electricity_supplier_id);


--
-- Name: index_groups_on_owner_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_owner_organization_id ON groups USING btree (owner_organization_id);


--
-- Name: index_groups_on_owner_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_owner_person_id ON groups USING btree (owner_person_id);


--
-- Name: index_groups_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_groups_on_slug ON groups USING btree (slug);


--
-- Name: index_groups_on_transmission_system_operator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_transmission_system_operator_id ON groups USING btree (transmission_system_operator_id);


--
-- Name: index_market_functions_on_organization_id_function; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_market_functions_on_organization_id_function ON organization_market_functions USING btree (organization_id, function);


--
-- Name: index_meters_on_broker_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meters_on_broker_id ON meters USING btree (broker_id);


--
-- Name: index_meters_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meters_on_group_id ON meters USING btree (group_id);


--
-- Name: index_meters_on_group_id_and_sequence_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_meters_on_group_id_and_sequence_number ON meters USING btree (group_id, sequence_number);


--
-- Name: index_organization_market_functions_on_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_market_functions_on_address_id ON organization_market_functions USING btree (address_id);


--
-- Name: index_organization_market_functions_on_contact_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_market_functions_on_contact_person_id ON organization_market_functions USING btree (contact_person_id);


--
-- Name: index_organization_market_functions_on_market_partner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organization_market_functions_on_market_partner_id ON organization_market_functions USING btree (market_partner_id);


--
-- Name: index_organization_market_functions_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_market_functions_on_organization_id ON organization_market_functions USING btree (organization_id);


--
-- Name: index_organizations_on_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_on_address_id ON organizations USING btree (address_id);


--
-- Name: index_organizations_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_on_contact_id ON organizations USING btree (contact_id);


--
-- Name: index_organizations_on_legal_representation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_on_legal_representation_id ON organizations USING btree (legal_representation_id);


--
-- Name: index_organizations_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organizations_on_slug ON organizations USING btree (slug);


--
-- Name: index_payments_on_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payments_on_contract_id ON payments USING btree (contract_id);


--
-- Name: index_persons_on_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_persons_on_address_id ON persons USING btree (address_id);


--
-- Name: index_persons_on_first_name_and_last_name_and_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_persons_on_first_name_and_last_name_and_email ON persons USING btree (first_name, last_name, email);


--
-- Name: index_persons_roles_on_person_id_and_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_persons_roles_on_person_id_and_role_id ON persons_roles USING btree (person_id, role_id);


--
-- Name: index_persons_roles_on_role_id_and_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_persons_roles_on_role_id_and_person_id ON persons_roles USING btree (role_id, person_id);


--
-- Name: index_readings_on_register_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_readings_on_register_id ON readings USING btree (register_id);


--
-- Name: index_readings_on_register_id_and_date_and_reason; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_readings_on_register_id_and_date_and_reason ON readings USING btree (register_id, date, reason);


--
-- Name: index_registers_on_meter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_registers_on_meter_id ON registers USING btree (meter_id);


--
-- Name: index_registers_on_meter_id_and_direction; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_registers_on_meter_id_and_direction ON registers USING btree (meter_id, direction);


--
-- Name: index_scores_on_scoreable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scores_on_scoreable_id ON scores USING btree (scoreable_id);


--
-- Name: index_scores_on_scoreable_id_and_scoreable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scores_on_scoreable_id_and_scoreable_type ON scores USING btree (scoreable_id, scoreable_type);


--
-- Name: index_tariffs_on_begin_date_and_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tariffs_on_begin_date_and_group_id ON tariffs USING btree (begin_date, group_id);


--
-- Name: index_tariffs_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tariffs_on_group_id ON tariffs USING btree (group_id);


--
-- Name: index_zip_to_prices_on_zip; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_zip_to_prices_on_zip ON zip_to_prices USING btree (zip);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: account_login_change_keys account_login_change_keys_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_login_change_keys
    ADD CONSTRAINT account_login_change_keys_id_fkey FOREIGN KEY (id) REFERENCES accounts(id);


--
-- Name: account_password_change_times account_password_change_times_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_password_change_times
    ADD CONSTRAINT account_password_change_times_id_fkey FOREIGN KEY (id) REFERENCES accounts(id);


--
-- Name: account_password_hashes account_password_hashes_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_password_hashes
    ADD CONSTRAINT account_password_hashes_id_fkey FOREIGN KEY (id) REFERENCES accounts(id);


--
-- Name: account_password_reset_keys account_password_reset_keys_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_password_reset_keys
    ADD CONSTRAINT account_password_reset_keys_id_fkey FOREIGN KEY (id) REFERENCES accounts(id);


--
-- Name: account_previous_password_hashes account_previous_password_hashes_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_previous_password_hashes
    ADD CONSTRAINT account_previous_password_hashes_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- Name: account_remember_keys account_remember_keys_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_remember_keys
    ADD CONSTRAINT account_remember_keys_id_fkey FOREIGN KEY (id) REFERENCES accounts(id);


--
-- Name: account_verification_keys account_verification_keys_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_verification_keys
    ADD CONSTRAINT account_verification_keys_id_fkey FOREIGN KEY (id) REFERENCES accounts(id);


--
-- Name: accounts accounts_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_person_id_fkey FOREIGN KEY (person_id) REFERENCES persons(id);


--
-- Name: accounts accounts_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_status_id_fkey FOREIGN KEY (status_id) REFERENCES account_statuses(id);


--
-- Name: bank_accounts fk_bank_accounts_organization; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bank_accounts
    ADD CONSTRAINT fk_bank_accounts_organization FOREIGN KEY (owner_organization_id) REFERENCES organizations(id);


--
-- Name: bank_accounts fk_bank_accounts_person; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bank_accounts
    ADD CONSTRAINT fk_bank_accounts_person FOREIGN KEY (owner_person_id) REFERENCES persons(id);


--
-- Name: billing_cycles fk_billing_cycles_localpool; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY billing_cycles
    ADD CONSTRAINT fk_billing_cycles_localpool FOREIGN KEY (localpool_id) REFERENCES groups(id);


--
-- Name: billings fk_billings_billing_cycles; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY billings
    ADD CONSTRAINT fk_billings_billing_cycles FOREIGN KEY (billing_cycle_id) REFERENCES billing_cycles(id);


--
-- Name: billings fk_billings_contracs; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY billings
    ADD CONSTRAINT fk_billings_contracs FOREIGN KEY (localpool_power_taker_contract_id) REFERENCES contracts(id);


--
-- Name: billings fk_billings_device_change_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY billings
    ADD CONSTRAINT fk_billings_device_change_1 FOREIGN KEY (device_change_reading_1_id) REFERENCES readings(id);


--
-- Name: billings fk_billings_device_change_2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY billings
    ADD CONSTRAINT fk_billings_device_change_2 FOREIGN KEY (device_change_reading_2_id) REFERENCES readings(id);


--
-- Name: billings fk_billings_end_reading; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY billings
    ADD CONSTRAINT fk_billings_end_reading FOREIGN KEY (end_reading_id) REFERENCES readings(id);


--
-- Name: billings fk_billings_start_reading; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY billings
    ADD CONSTRAINT fk_billings_start_reading FOREIGN KEY (start_reading_id) REFERENCES readings(id);


--
-- Name: contracts fk_contracts_contractor_bank_account; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contracts
    ADD CONSTRAINT fk_contracts_contractor_bank_account FOREIGN KEY (contractor_bank_account_id) REFERENCES bank_accounts(id);


--
-- Name: contracts fk_contracts_contractor_organization; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contracts
    ADD CONSTRAINT fk_contracts_contractor_organization FOREIGN KEY (contractor_organization_id) REFERENCES organizations(id);


--
-- Name: contracts fk_contracts_contractor_person; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contracts
    ADD CONSTRAINT fk_contracts_contractor_person FOREIGN KEY (contractor_person_id) REFERENCES persons(id);


--
-- Name: contracts fk_contracts_customer_bank_account; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contracts
    ADD CONSTRAINT fk_contracts_customer_bank_account FOREIGN KEY (customer_bank_account_id) REFERENCES bank_accounts(id);


--
-- Name: contracts fk_contracts_customer_organization; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contracts
    ADD CONSTRAINT fk_contracts_customer_organization FOREIGN KEY (customer_organization_id) REFERENCES organizations(id);


--
-- Name: contracts fk_contracts_customer_person; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contracts
    ADD CONSTRAINT fk_contracts_customer_person FOREIGN KEY (customer_person_id) REFERENCES persons(id);


--
-- Name: contracts fk_contracts_localpool; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contracts
    ADD CONSTRAINT fk_contracts_localpool FOREIGN KEY (localpool_id) REFERENCES groups(id);


--
-- Name: contracts fk_contracts_register; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contracts
    ADD CONSTRAINT fk_contracts_register FOREIGN KEY (register_id) REFERENCES registers(id);


--
-- Name: contracts_tariffs fk_contracts_tariffs_contract; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contracts_tariffs
    ADD CONSTRAINT fk_contracts_tariffs_contract FOREIGN KEY (contract_id) REFERENCES contracts(id);


--
-- Name: contracts_tariffs fk_contracts_tariffs_tariff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contracts_tariffs
    ADD CONSTRAINT fk_contracts_tariffs_tariff FOREIGN KEY (tariff_id) REFERENCES tariffs(id);


--
-- Name: formula_parts fk_formula_parts_operand; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY formula_parts
    ADD CONSTRAINT fk_formula_parts_operand FOREIGN KEY (operand_id) REFERENCES registers(id);


--
-- Name: formula_parts fk_formula_parts_register; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY formula_parts
    ADD CONSTRAINT fk_formula_parts_register FOREIGN KEY (register_id) REFERENCES registers(id);


--
-- Name: groups fk_groups_address; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT fk_groups_address FOREIGN KEY (address_id) REFERENCES addresses(id);


--
-- Name: groups fk_groups_distribution_system_operator; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT fk_groups_distribution_system_operator FOREIGN KEY (distribution_system_operator_id) REFERENCES organizations(id);


--
-- Name: groups fk_groups_electricity_supplier; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT fk_groups_electricity_supplier FOREIGN KEY (electricity_supplier_id) REFERENCES organizations(id);


--
-- Name: groups fk_groups_organization; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT fk_groups_organization FOREIGN KEY (owner_organization_id) REFERENCES organizations(id);


--
-- Name: groups fk_groups_person; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT fk_groups_person FOREIGN KEY (owner_person_id) REFERENCES persons(id);


--
-- Name: groups fk_groups_transmission_system_operator; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT fk_groups_transmission_system_operator FOREIGN KEY (transmission_system_operator_id) REFERENCES organizations(id);


--
-- Name: meters fk_meters_broker; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meters
    ADD CONSTRAINT fk_meters_broker FOREIGN KEY (broker_id) REFERENCES brokers(id);


--
-- Name: meters fk_meters_group; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meters
    ADD CONSTRAINT fk_meters_group FOREIGN KEY (group_id) REFERENCES groups(id);


--
-- Name: organization_market_functions fk_organization_market_functions_address; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organization_market_functions
    ADD CONSTRAINT fk_organization_market_functions_address FOREIGN KEY (address_id) REFERENCES addresses(id);


--
-- Name: organization_market_functions fk_organization_market_functions_contact_person; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organization_market_functions
    ADD CONSTRAINT fk_organization_market_functions_contact_person FOREIGN KEY (contact_person_id) REFERENCES persons(id);


--
-- Name: organization_market_functions fk_organization_market_functions_organization; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organization_market_functions
    ADD CONSTRAINT fk_organization_market_functions_organization FOREIGN KEY (organization_id) REFERENCES organizations(id);


--
-- Name: persons fk_organizations_address; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY persons
    ADD CONSTRAINT fk_organizations_address FOREIGN KEY (address_id) REFERENCES addresses(id);


--
-- Name: organizations fk_organizations_address; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT fk_organizations_address FOREIGN KEY (address_id) REFERENCES addresses(id);


--
-- Name: organizations fk_organizations_contact; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT fk_organizations_contact FOREIGN KEY (contact_id) REFERENCES persons(id);


--
-- Name: organizations fk_organizations_customer_number; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT fk_organizations_customer_number FOREIGN KEY (customer_number) REFERENCES customer_numbers(id);


--
-- Name: organizations fk_organizations_legal_representation; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT fk_organizations_legal_representation FOREIGN KEY (legal_representation_id) REFERENCES persons(id);


--
-- Name: payments fk_payments_contract; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT fk_payments_contract FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE CASCADE;


--
-- Name: persons fk_persons_customer_number; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY persons
    ADD CONSTRAINT fk_persons_customer_number FOREIGN KEY (customer_number) REFERENCES customer_numbers(id);


--
-- Name: readings fk_readings_register; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY readings
    ADD CONSTRAINT fk_readings_register FOREIGN KEY (register_id) REFERENCES registers(id);


--
-- Name: registers fk_registers_meter; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY registers
    ADD CONSTRAINT fk_registers_meter FOREIGN KEY (meter_id) REFERENCES meters(id);


--
-- Name: tariffs fk_tariffs_group; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tariffs
    ADD CONSTRAINT fk_tariffs_group FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE;


--
-- Name: contract_tax_data fk_tax_data_contract; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contract_tax_data
    ADD CONSTRAINT fk_tax_data_contract FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20140403173451');

INSERT INTO schema_migrations (version) VALUES ('20150630104513');

INSERT INTO schema_migrations (version) VALUES ('20170524090229');

INSERT INTO schema_migrations (version) VALUES ('20170712163547');

INSERT INTO schema_migrations (version) VALUES ('20170909015357');

INSERT INTO schema_migrations (version) VALUES ('20171010075030');

INSERT INTO schema_migrations (version) VALUES ('20171028142114');

INSERT INTO schema_migrations (version) VALUES ('20171028200020');

INSERT INTO schema_migrations (version) VALUES ('20171028200030');

INSERT INTO schema_migrations (version) VALUES ('20171028200040');

INSERT INTO schema_migrations (version) VALUES ('20171028200050');

INSERT INTO schema_migrations (version) VALUES ('20171028200100');

INSERT INTO schema_migrations (version) VALUES ('20171028200200');

INSERT INTO schema_migrations (version) VALUES ('20171028200400');

INSERT INTO schema_migrations (version) VALUES ('20171028200600');

INSERT INTO schema_migrations (version) VALUES ('20171029000000');

INSERT INTO schema_migrations (version) VALUES ('20171029000100');

INSERT INTO schema_migrations (version) VALUES ('20171029000800');

INSERT INTO schema_migrations (version) VALUES ('20171029000900');

INSERT INTO schema_migrations (version) VALUES ('20171031085200');

INSERT INTO schema_migrations (version) VALUES ('20171031085260');

INSERT INTO schema_migrations (version) VALUES ('20171031085270');

INSERT INTO schema_migrations (version) VALUES ('20171031085280');

INSERT INTO schema_migrations (version) VALUES ('20171031085290');

INSERT INTO schema_migrations (version) VALUES ('20171031085300');

INSERT INTO schema_migrations (version) VALUES ('20171031085310');

INSERT INTO schema_migrations (version) VALUES ('20171031085320');

INSERT INTO schema_migrations (version) VALUES ('20171031085330');

INSERT INTO schema_migrations (version) VALUES ('20171031085340');

INSERT INTO schema_migrations (version) VALUES ('20171031085350');

INSERT INTO schema_migrations (version) VALUES ('20171031085360');

INSERT INTO schema_migrations (version) VALUES ('20171115086500');

INSERT INTO schema_migrations (version) VALUES ('20171207154218');

INSERT INTO schema_migrations (version) VALUES ('20180112000000');

