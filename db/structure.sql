--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.5
-- Dumped by pg_dump version 9.6.5

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
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

--
-- Name: contract_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE contract_status AS ENUM (
    'onboarding',
    'approvedactive',
    'terminated',
    'ended'
);


--
-- Name: country; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE country AS ENUM (
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
-- Name: direction; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE direction AS ENUM (
    'in',
    'out'
);


--
-- Name: direction_number; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE direction_number AS ENUM (
    'ERZ',
    'ZRZ'
);


--
-- Name: edifact_cycle_interval; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE edifact_cycle_interval AS ENUM (
    'MONTHLY',
    'YEARLY',
    'QUARTERLY',
    'HALF_YEARLY'
);


--
-- Name: edifact_data_logging; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE edifact_data_logging AS ENUM (
    'Z04',
    'Z05'
);


--
-- Name: edifact_measurement_method; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE edifact_measurement_method AS ENUM (
    'AMR',
    'MMR'
);


--
-- Name: edifact_meter_size; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE edifact_meter_size AS ENUM (
    'Z01',
    'Z02',
    'Z03'
);


--
-- Name: edifact_metering_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE edifact_metering_type AS ENUM (
    'AHZ',
    'LAZ',
    'WSZ',
    'EHZ',
    'MAZ',
    'IVA'
);


--
-- Name: edifact_mounting_method; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE edifact_mounting_method AS ENUM (
    'BKE',
    'DPA',
    'HS'
);


--
-- Name: edifact_tariff; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE edifact_tariff AS ENUM (
    'ETZ',
    'ZTZ',
    'NTZ'
);


--
-- Name: edifact_voltage_level; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE edifact_voltage_level AS ENUM (
    'E06',
    'E05',
    'E04',
    'E03'
);


--
-- Name: label; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE label AS ENUM (
    'CONSUMPTION',
    'DEMARCATION_PV',
    'DEMARCATION_CHP',
    'PRODUCTION_PV',
    'PRODUCTION_CHP',
    'GRID_CONSUMPTION',
    'GRID_FEEDING',
    'GRID_CONSUMPTION_CORRECTED',
    'GRID_FEEDING_CORRECTED',
    'OTHER'
);


--
-- Name: manufacturer_name; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE manufacturer_name AS ENUM (
    'easy_meter',
    'amperix',
    'ferraris',
    'other'
);


--
-- Name: operator; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE operator AS ENUM (
    '+',
    '-'
);


--
-- Name: ownership; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE ownership AS ENUM (
    'BUZZN_SYSTEMS',
    'FOREIGN_OWNERSHIP',
    'CUSTOMER',
    'LEASED',
    'BOUGHT'
);


--
-- Name: preferred_language; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE preferred_language AS ENUM (
    'de',
    'en'
);


--
-- Name: prefix; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE prefix AS ENUM (
    'F',
    'M'
);


--
-- Name: quality; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE quality AS ENUM (
    '20',
    '67',
    '79',
    '187',
    '220',
    '201'
);


--
-- Name: read_by; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE read_by AS ENUM (
    'BN',
    'SN',
    'SG',
    'VNB'
);


--
-- Name: reason; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE reason AS ENUM (
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
-- Name: section; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE section AS ENUM (
    'S',
    'G'
);


--
-- Name: source; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE source AS ENUM (
    'SM',
    'MAN'
);


--
-- Name: state; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE state AS ENUM (
    'DE_BB',
    'DE_BE',
    'DE_BW',
    'DE_BY',
    'DE_HB',
    'DE_HE',
    'DE_HH',
    'DE_MV',
    'DE_NI',
    'DE_NW',
    'DE_RP',
    'DE_SH',
    'DE_SL',
    'DE_SN',
    'DE_ST',
    'DE_TH'
);


--
-- Name: status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE status AS ENUM (
    'Z83',
    'Z84',
    'Z86'
);


--
-- Name: taxation; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE taxation AS ENUM (
    'F',
    'R'
);


--
-- Name: title; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE title AS ENUM (
    'Dr.',
    'Prof.',
    'Prof. Dr.'
);


--
-- Name: unit; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE unit AS ENUM (
    'Wh',
    'W',
    'm³'
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: active_admin_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE active_admin_comments (
    id integer NOT NULL,
    namespace character varying,
    body text,
    resource_id integer,
    resource_type character varying,
    author_id integer,
    author_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE active_admin_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE active_admin_comments_id_seq OWNED BY active_admin_comments.id;


--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE addresses (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    city character varying,
    zip character varying(16) NOT NULL,
    longitude double precision,
    latitude double precision,
    addressable_id uuid,
    addressable_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    addition character varying,
    street character varying(64) NOT NULL,
    state state,
    country country DEFAULT 'DE'::country NOT NULL
);


--
-- Name: bank_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE bank_accounts (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    slug character varying,
    holder character varying,
    encrypted_iban character varying,
    bic character varying,
    bank_name character varying,
    direct_debit boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    contracting_party_id uuid,
    contracting_party_type character varying
);


--
-- Name: banks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE banks (
    id integer NOT NULL,
    blz character varying,
    description character varying,
    zip character varying,
    place character varying,
    name character varying,
    bic character varying
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
    begin_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,
    name character varying NOT NULL,
    localpool_id uuid,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: billings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE billings (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    status character varying NOT NULL,
    total_energy_consumption_kwh integer NOT NULL,
    total_price_cents integer NOT NULL,
    prepayments_cents integer NOT NULL,
    receivables_cents integer NOT NULL,
    invoice_number character varying,
    start_reading_id character varying NOT NULL,
    end_reading_id character varying NOT NULL,
    device_change_reading_1_id character varying,
    device_change_reading_2_id character varying,
    billing_cycle_id uuid,
    localpool_power_taker_contract_id uuid,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: brokers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE brokers (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    mode character varying NOT NULL,
    external_id character varying,
    provider_login character varying NOT NULL,
    encrypted_provider_password character varying NOT NULL,
    encrypted_provider_token_key character varying,
    encrypted_provider_token_secret character varying,
    resource_id uuid NOT NULL,
    resource_type character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    type character varying NOT NULL,
    consumer_key character varying,
    consumer_secret character varying
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE comments (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    commentable_id uuid,
    commentable_type character varying,
    title character varying,
    body text,
    subject character varying,
    user_id uuid NOT NULL,
    lft integer,
    rgt integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    likes integer DEFAULT 0,
    parent_id uuid,
    image character varying,
    chart_resolution character varying,
    chart_timestamp timestamp without time zone
);


--
-- Name: contracts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE contracts (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    slug character varying,
    forecast_kwh_pa bigint,
    signing_date date,
    end_date date,
    terms_accepted boolean,
    confirm_pricing_model boolean,
    power_of_attorney boolean,
    customer_number character varying,
    register_id uuid,
    organization_id uuid,
    localpool_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    other_contract boolean,
    move_in boolean,
    begin_date date,
    "authorization" boolean,
    feedback text,
    attention_by text,
    third_party_billing_number character varying,
    third_party_renter_number character varying,
    first_master_uid character varying,
    second_master_uid character varying,
    metering_point_operator_name character varying,
    old_supplier_name character varying,
    type character varying NOT NULL,
    cancellation_date date,
    old_customer_number character varying,
    old_account_number character varying,
    customer_id uuid,
    customer_type character varying,
    contractor_id uuid,
    contractor_type character varying,
    energy_consumption_before_kwh_pa character varying,
    down_payment_before_cents_per_month character varying,
    contract_number integer,
    contract_number_addition integer,
    customer_bank_account_id uuid,
    contractor_bank_account_id uuid,
    signing_user character varying,
    status contract_status DEFAULT 'onboarding'::contract_status,
    renewable_energy_law_taxation taxation
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
    register_id uuid,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE documents (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    path character varying NOT NULL,
    encryption_details character varying NOT NULL,
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
    register_id uuid,
    operand_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    operator operator NOT NULL
);


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE groups (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    slug character varying,
    name character varying,
    logo character varying,
    website character varying,
    image character varying,
    readable character varying,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    type character varying NOT NULL
);


--
-- Name: meters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE meters (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    product_name character varying,
    product_serialnumber character varying,
    metering_type character varying,
    meter_size character varying,
    measurement_capture character varying,
    mounting_method character varying,
    calibrated_until date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    type character varying NOT NULL,
    voltage_level character varying,
    cycle_interval character varying,
    tariff character varying,
    data_logging character varying,
    converter_constant integer,
    edifact_voltage_level edifact_voltage_level,
    edifact_cycle_interval edifact_cycle_interval,
    edifact_metering_type edifact_metering_type,
    edifact_meter_size edifact_meter_size,
    edifact_tariff edifact_tariff,
    edifact_data_logging edifact_data_logging,
    edifact_measurement_method edifact_measurement_method,
    edifact_mounting_method edifact_mounting_method,
    ownership ownership,
    direction_number direction_number,
    section section,
    manufacturer_name manufacturer_name,
    build_year integer,
    sent_data_dso date,
    "position" integer,
    group_id uuid
);


--
-- Name: nne_vnbs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE nne_vnbs (
    verbandsnummer character varying NOT NULL,
    typ character varying,
    messung_et double precision,
    abrechnung_et double precision,
    zaehler_et double precision,
    mp_et double precision,
    messung_dt double precision,
    abrechnung_dt double precision,
    zaehler_dt double precision,
    mp_dt double precision,
    arbeitspreis double precision,
    grundpreis double precision,
    vorlaeufig boolean
);


--
-- Name: oauth_access_grants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE oauth_access_grants (
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying,
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    resource_owner_id uuid DEFAULT uuid_generate_v4(),
    application_id uuid DEFAULT uuid_generate_v4()
);


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE oauth_access_tokens (
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying,
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    resource_owner_id uuid DEFAULT uuid_generate_v4(),
    application_id uuid DEFAULT uuid_generate_v4()
);


--
-- Name: oauth_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE oauth_applications (
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri text NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    owner_id uuid,
    owner_type character varying,
    id uuid DEFAULT uuid_generate_v4() NOT NULL
);


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE organizations (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    slug character varying,
    image character varying,
    name character varying,
    email character varying,
    edifactemail character varying,
    phone character varying,
    fax character varying,
    description character varying,
    website character varying,
    mode character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    market_place_id character varying,
    represented_by character varying,
    sales_tax_number integer,
    tax_rate double precision,
    tax_number integer,
    retailer boolean,
    provider_permission boolean,
    subject_to_tax boolean,
    mandate_reference character varying,
    creditor_id character varying,
    account_number character varying,
    contact_id uuid
);


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE payments (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    begin_date date NOT NULL,
    end_date date,
    price_cents integer NOT NULL,
    cycle character varying,
    source character varying,
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
    title title,
    prefix prefix,
    preferred_language preferred_language,
    sales_tax_number integer,
    tax_rate double precision,
    tax_number integer,
    retailer boolean,
    provider_permission boolean,
    subject_to_tax boolean,
    mandate_reference character varying,
    creditor_id character varying,
    image character varying
);


--
-- Name: prices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE prices (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    baseprice_cents_per_month integer NOT NULL,
    energyprice_cents_per_kilowatt_hour double precision NOT NULL,
    begin_date date NOT NULL,
    localpool_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE profiles (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_name character varying,
    slug character varying,
    title character varying,
    image character varying,
    first_name character varying,
    last_name character varying,
    about_me text,
    website character varying,
    gender character varying,
    phone character varying,
    time_zone character varying,
    confirm_pricing_model boolean,
    terms boolean,
    readable character varying,
    user_id uuid,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    email_notification_meter_offline boolean DEFAULT false,
    address character varying
);


--
-- Name: readings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE readings (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    date date,
    raw_value double precision NOT NULL,
    value double precision NOT NULL,
    comment character varying(256),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    unit unit,
    reason reason,
    read_by read_by,
    quality quality,
    source source,
    status status,
    register_id uuid NOT NULL
);


--
-- Name: registers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE registers (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    metering_point_id character varying,
    name character varying,
    image character varying,
    meter_id uuid,
    group_id uuid,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observer_enabled boolean DEFAULT false,
    observer_min_threshold integer DEFAULT 100,
    observer_max_threshold integer DEFAULT 5000,
    last_observed timestamp without time zone,
    observer_offline_monitoring boolean DEFAULT false,
    type character varying NOT NULL,
    obis character varying,
    pre_decimal_position integer,
    post_decimal_position integer,
    low_load_ability boolean,
    direction direction,
    label label,
    share_with_group boolean DEFAULT true NOT NULL,
    share_publicly boolean DEFAULT false NOT NULL
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying,
    resource_id uuid,
    resource_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
    name character varying NOT NULL,
    begin_date date NOT NULL,
    end_date date,
    energyprice_cents_per_kwh integer NOT NULL,
    baseprice_cents_per_month integer NOT NULL,
    contract_id uuid NOT NULL
);


--
-- Name: used_zip_sns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE used_zip_sns (
    id integer NOT NULL,
    zip character varying,
    kwh integer,
    price double precision,
    created_at timestamp without time zone
);


--
-- Name: used_zip_sns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE used_zip_sns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: used_zip_sns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE used_zip_sns_id_seq OWNED BY used_zip_sns.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying,
    locked_at timestamp without time zone,
    invitation_token character varying,
    invitation_created_at timestamp without time zone,
    invitation_sent_at timestamp without time zone,
    invitation_accepted_at timestamp without time zone,
    invitation_limit integer,
    invited_by_type character varying,
    invitations_count integer DEFAULT 0,
    group_id uuid,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    provider character varying,
    uid character varying,
    invited_by_id uuid,
    invitation_message text,
    data_protection_guidelines text,
    terms_of_use text,
    sales_tax_number integer,
    tax_rate double precision,
    tax_number integer,
    retailer boolean,
    provider_permission boolean,
    subject_to_tax boolean,
    mandate_reference character varying,
    creditor_id character varying,
    account_number character varying,
    person_id uuid
);


--
-- Name: users_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users_roles (
    user_id uuid,
    role_id integer
);


--
-- Name: zip_kas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE zip_kas (
    zip character varying NOT NULL,
    ka double precision
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
    state character varying NOT NULL,
    community character varying NOT NULL,
    vdewid bigint NOT NULL,
    dso character varying NOT NULL,
    updated boolean NOT NULL
);


--
-- Name: zip_vnbs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE zip_vnbs (
    id integer NOT NULL,
    zip character varying,
    place character varying,
    verbandsnummer character varying
);


--
-- Name: zip_vnbs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE zip_vnbs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: zip_vnbs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE zip_vnbs_id_seq OWNED BY zip_vnbs.id;


--
-- Name: active_admin_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY active_admin_comments ALTER COLUMN id SET DEFAULT nextval('active_admin_comments_id_seq'::regclass);


--
-- Name: banks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY banks ALTER COLUMN id SET DEFAULT nextval('banks_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: used_zip_sns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY used_zip_sns ALTER COLUMN id SET DEFAULT nextval('used_zip_sns_id_seq'::regclass);


--
-- Name: zip_vnbs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY zip_vnbs ALTER COLUMN id SET DEFAULT nextval('zip_vnbs_id_seq'::regclass);


--
-- Name: active_admin_comments active_admin_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY active_admin_comments
    ADD CONSTRAINT active_admin_comments_pkey PRIMARY KEY (id);


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
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


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
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: brokers discovergy_brokers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY brokers
    ADD CONSTRAINT discovergy_brokers_pkey PRIMARY KEY (id);


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
-- Name: registers metering_points_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY registers
    ADD CONSTRAINT metering_points_pkey PRIMARY KEY (id);


--
-- Name: meters meters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meters
    ADD CONSTRAINT meters_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants oauth_access_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications oauth_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


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
-- Name: prices prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY prices
    ADD CONSTRAINT prices_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: readings readings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY readings
    ADD CONSTRAINT readings_pkey PRIMARY KEY (id);


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
-- Name: used_zip_sns used_zip_sns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY used_zip_sns
    ADD CONSTRAINT used_zip_sns_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: zip_to_prices zip_to_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY zip_to_prices
    ADD CONSTRAINT zip_to_prices_pkey PRIMARY KEY (id);


--
-- Name: zip_vnbs zip_vnbs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY zip_vnbs
    ADD CONSTRAINT zip_vnbs_pkey PRIMARY KEY (id);


--
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON active_admin_comments USING btree (author_type, author_id);


--
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_namespace ON active_admin_comments USING btree (namespace);


--
-- Name: index_active_admin_comments_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_resource_type_and_resource_id ON active_admin_comments USING btree (resource_type, resource_id);


--
-- Name: index_addressable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_addressable ON addresses USING btree (addressable_id, addressable_type);


--
-- Name: index_bank_accounts_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_bank_accounts_on_slug ON bank_accounts USING btree (slug);


--
-- Name: index_banks_on_bic; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_banks_on_bic ON banks USING btree (bic);


--
-- Name: index_banks_on_blz; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_banks_on_blz ON banks USING btree (blz);


--
-- Name: index_billing_cycles_dates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billing_cycles_dates ON billing_cycles USING btree (begin_date, end_date);


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
-- Name: index_billings_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billings_on_status ON billings USING btree (status);


--
-- Name: index_brokers; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_brokers ON brokers USING btree (mode, resource_id, resource_type);


--
-- Name: index_brokers_resources; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_brokers_resources ON brokers USING btree (resource_type, resource_id);


--
-- Name: index_comments_on_commentable_id_and_commentable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_commentable_id_and_commentable_type ON comments USING btree (commentable_id, commentable_type);


--
-- Name: index_comments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_user_id ON comments USING btree (user_id);


--
-- Name: index_contract_number_and_its_addition; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_contract_number_and_its_addition ON contracts USING btree (contract_number, contract_number_addition);


--
-- Name: index_contracts_on_contract_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_contract_number ON contracts USING btree (contract_number);


--
-- Name: index_contracts_on_contractor_type_and_contractor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_contractor_type_and_contractor_id ON contracts USING btree (contractor_type, contractor_id);


--
-- Name: index_contracts_on_customer_type_and_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_customer_type_and_customer_id ON contracts USING btree (customer_type, customer_id);


--
-- Name: index_contracts_on_localpool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_localpool_id ON contracts USING btree (localpool_id);


--
-- Name: index_contracts_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_organization_id ON contracts USING btree (organization_id);


--
-- Name: index_contracts_on_register_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_register_id ON contracts USING btree (register_id);


--
-- Name: index_contracts_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_contracts_on_slug ON contracts USING btree (slug);


--
-- Name: index_devices_on_register_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_devices_on_register_id ON devices USING btree (register_id);


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
-- Name: index_groups_on_readable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_readable ON groups USING btree (readable);


--
-- Name: index_groups_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_groups_on_slug ON groups USING btree (slug);


--
-- Name: index_meters_on_group_id_and_position; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_meters_on_group_id_and_position ON meters USING btree (group_id, "position");


--
-- Name: index_nne_vnbs_on_verbandsnummer; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_nne_vnbs_on_verbandsnummer ON nne_vnbs USING btree (verbandsnummer);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_owner_id_and_owner_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_applications_on_owner_id_and_owner_type ON oauth_applications USING btree (owner_id, owner_type);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON oauth_applications USING btree (uid);


--
-- Name: index_organizations_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_on_contact_id ON organizations USING btree (contact_id);


--
-- Name: index_organizations_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organizations_on_slug ON organizations USING btree (slug);


--
-- Name: index_payments_on_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payments_on_contract_id ON payments USING btree (contract_id);


--
-- Name: index_persons_on_first_name_and_last_name_and_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_persons_on_first_name_and_last_name_and_email ON persons USING btree (first_name, last_name, email);


--
-- Name: index_prices_on_begin_date_and_localpool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_prices_on_begin_date_and_localpool_id ON prices USING btree (begin_date, localpool_id);


--
-- Name: index_profiles_on_readable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_profiles_on_readable ON profiles USING btree (readable);


--
-- Name: index_profiles_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_profiles_on_slug ON profiles USING btree (slug);


--
-- Name: index_profiles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_profiles_on_user_id ON profiles USING btree (user_id);


--
-- Name: index_profiles_on_user_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_profiles_on_user_name ON profiles USING btree (user_name);


--
-- Name: index_readings_on_register_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_readings_on_register_id ON readings USING btree (register_id);


--
-- Name: index_readings_on_register_id_and_date_and_reason; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_readings_on_register_id_and_date_and_reason ON readings USING btree (register_id, date, reason);


--
-- Name: index_registers_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_registers_on_group_id ON registers USING btree (group_id);


--
-- Name: index_registers_on_meter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_registers_on_meter_id ON registers USING btree (meter_id);


--
-- Name: index_roles_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_name ON roles USING btree (name);


--
-- Name: index_roles_on_name_and_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_name_and_resource_type_and_resource_id ON roles USING btree (name, resource_type, resource_id);


--
-- Name: index_scores_on_scoreable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scores_on_scoreable_id ON scores USING btree (scoreable_id);


--
-- Name: index_scores_on_scoreable_id_and_scoreable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scores_on_scoreable_id_and_scoreable_type ON scores USING btree (scoreable_id, scoreable_type);


--
-- Name: index_tariffs_on_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tariffs_on_contract_id ON tariffs USING btree (contract_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_group_id ON users USING btree (group_id);


--
-- Name: index_users_on_invitation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_invitation_token ON users USING btree (invitation_token);


--
-- Name: index_users_on_invitations_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invitations_count ON users USING btree (invitations_count);


--
-- Name: index_users_on_invited_by_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invited_by_type ON users USING btree (invited_by_type);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON users USING btree (unlock_token);


--
-- Name: index_users_roles_on_user_id_and_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_roles_on_user_id_and_role_id ON users_roles USING btree (user_id, role_id);


--
-- Name: index_zip_kas_on_zip; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_zip_kas_on_zip ON zip_kas USING btree (zip);


--
-- Name: index_zip_to_prices_on_zip; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_zip_to_prices_on_zip ON zip_to_prices USING btree (zip);


--
-- Name: index_zip_vnbs_on_zip; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_zip_vnbs_on_zip ON zip_vnbs USING btree (zip);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: meters fk_rails_276fdd6a78; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meters
    ADD CONSTRAINT fk_rails_276fdd6a78 FOREIGN KEY (group_id) REFERENCES groups(id);


--
-- Name: organizations fk_rails_6b54950e91; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT fk_rails_6b54950e91 FOREIGN KEY (contact_id) REFERENCES persons(id);


--
-- Name: registers fk_rails_88c9092860; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY registers
    ADD CONSTRAINT fk_rails_88c9092860 FOREIGN KEY (meter_id) REFERENCES meters(id);


--
-- Name: payments fk_rails_9215ad6069; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT fk_rails_9215ad6069 FOREIGN KEY (contract_id) REFERENCES contracts(id);


--
-- Name: readings fk_rails_9a330278de; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY readings
    ADD CONSTRAINT fk_rails_9a330278de FOREIGN KEY (register_id) REFERENCES registers(id);


--
-- Name: tariffs fk_rails_e863d6119e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tariffs
    ADD CONSTRAINT fk_rails_e863d6119e FOREIGN KEY (contract_id) REFERENCES contracts(id);


--
-- Name: users fk_rails_fa67535741; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_rails_fa67535741 FOREIGN KEY (person_id) REFERENCES persons(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20140227153812');

INSERT INTO schema_migrations (version) VALUES ('20140228132245');

INSERT INTO schema_migrations (version) VALUES ('20140228140847');

INSERT INTO schema_migrations (version) VALUES ('20140305164111');

INSERT INTO schema_migrations (version) VALUES ('20140321105035');

INSERT INTO schema_migrations (version) VALUES ('20140321112525');

INSERT INTO schema_migrations (version) VALUES ('20140402111832');

INSERT INTO schema_migrations (version) VALUES ('20140403165004');

INSERT INTO schema_migrations (version) VALUES ('20140403173451');

INSERT INTO schema_migrations (version) VALUES ('20140404074440');

INSERT INTO schema_migrations (version) VALUES ('20140404124546');

INSERT INTO schema_migrations (version) VALUES ('20140407122119');

INSERT INTO schema_migrations (version) VALUES ('20140409092046');

INSERT INTO schema_migrations (version) VALUES ('20140416193045');

INSERT INTO schema_migrations (version) VALUES ('20140515074138');

INSERT INTO schema_migrations (version) VALUES ('20140528121619');

INSERT INTO schema_migrations (version) VALUES ('20140528181340');

INSERT INTO schema_migrations (version) VALUES ('20140605130856');

INSERT INTO schema_migrations (version) VALUES ('20140616081945');

INSERT INTO schema_migrations (version) VALUES ('20140616100740');

INSERT INTO schema_migrations (version) VALUES ('20140622154815');

INSERT INTO schema_migrations (version) VALUES ('20140730084558');

INSERT INTO schema_migrations (version) VALUES ('20140930083931');

INSERT INTO schema_migrations (version) VALUES ('20141112082237');

INSERT INTO schema_migrations (version) VALUES ('20141112082238');

INSERT INTO schema_migrations (version) VALUES ('20141112082239');

INSERT INTO schema_migrations (version) VALUES ('20141112082240');

INSERT INTO schema_migrations (version) VALUES ('20150114092836');

INSERT INTO schema_migrations (version) VALUES ('20150219151449');

INSERT INTO schema_migrations (version) VALUES ('20150325094707');

INSERT INTO schema_migrations (version) VALUES ('20150327135326');

INSERT INTO schema_migrations (version) VALUES ('20150407152833');

INSERT INTO schema_migrations (version) VALUES ('20150613142417');

INSERT INTO schema_migrations (version) VALUES ('20150619095317');

INSERT INTO schema_migrations (version) VALUES ('20150625114349');

INSERT INTO schema_migrations (version) VALUES ('20150626153325');

INSERT INTO schema_migrations (version) VALUES ('20150630104513');

INSERT INTO schema_migrations (version) VALUES ('20150722092022');

INSERT INTO schema_migrations (version) VALUES ('20150820103035');

INSERT INTO schema_migrations (version) VALUES ('20150831134142');

INSERT INTO schema_migrations (version) VALUES ('20150904104902');

INSERT INTO schema_migrations (version) VALUES ('20150916104557');

INSERT INTO schema_migrations (version) VALUES ('20150923161601');

INSERT INTO schema_migrations (version) VALUES ('20150925090918');

INSERT INTO schema_migrations (version) VALUES ('20151007092822');

INSERT INTO schema_migrations (version) VALUES ('20151012151021');

INSERT INTO schema_migrations (version) VALUES ('20151023150629');

INSERT INTO schema_migrations (version) VALUES ('20151109114235');

INSERT INTO schema_migrations (version) VALUES ('20151203091129');

INSERT INTO schema_migrations (version) VALUES ('20151209101130');

INSERT INTO schema_migrations (version) VALUES ('20160120084020');

INSERT INTO schema_migrations (version) VALUES ('20160217120441');

INSERT INTO schema_migrations (version) VALUES ('20160217143008');

INSERT INTO schema_migrations (version) VALUES ('20160217143754');

INSERT INTO schema_migrations (version) VALUES ('20160217143947');

INSERT INTO schema_migrations (version) VALUES ('20160218132858');

INSERT INTO schema_migrations (version) VALUES ('20160218132922');

INSERT INTO schema_migrations (version) VALUES ('20160218133232');

INSERT INTO schema_migrations (version) VALUES ('20160218133241');

INSERT INTO schema_migrations (version) VALUES ('20160223100219');

INSERT INTO schema_migrations (version) VALUES ('20160413090939');

INSERT INTO schema_migrations (version) VALUES ('20160422110752');

INSERT INTO schema_migrations (version) VALUES ('20160602120455');

INSERT INTO schema_migrations (version) VALUES ('20160622110731');

INSERT INTO schema_migrations (version) VALUES ('20160622111108');

INSERT INTO schema_migrations (version) VALUES ('20160802083615');

INSERT INTO schema_migrations (version) VALUES ('20160921155654');

INSERT INTO schema_migrations (version) VALUES ('20160922130534');

INSERT INTO schema_migrations (version) VALUES ('20160922154043');

INSERT INTO schema_migrations (version) VALUES ('20160922163350');

INSERT INTO schema_migrations (version) VALUES ('20160926060807');

INSERT INTO schema_migrations (version) VALUES ('20160926135606');

INSERT INTO schema_migrations (version) VALUES ('20160926140111');

INSERT INTO schema_migrations (version) VALUES ('20160926140416');

INSERT INTO schema_migrations (version) VALUES ('20160926140754');

INSERT INTO schema_migrations (version) VALUES ('20161019155654');

INSERT INTO schema_migrations (version) VALUES ('20161020085343');

INSERT INTO schema_migrations (version) VALUES ('20161110152656');

INSERT INTO schema_migrations (version) VALUES ('20161110152952');

INSERT INTO schema_migrations (version) VALUES ('20161110184053');

INSERT INTO schema_migrations (version) VALUES ('20161115085848');

INSERT INTO schema_migrations (version) VALUES ('20161115150524');

INSERT INTO schema_migrations (version) VALUES ('20161116104658');

INSERT INTO schema_migrations (version) VALUES ('20161116115800');

INSERT INTO schema_migrations (version) VALUES ('20161116122929');

INSERT INTO schema_migrations (version) VALUES ('20161116133815');

INSERT INTO schema_migrations (version) VALUES ('20161116135219');

INSERT INTO schema_migrations (version) VALUES ('20161116135644');

INSERT INTO schema_migrations (version) VALUES ('20161116135708');

INSERT INTO schema_migrations (version) VALUES ('20161116135725');

INSERT INTO schema_migrations (version) VALUES ('20161116140032');

INSERT INTO schema_migrations (version) VALUES ('20161116143256');

INSERT INTO schema_migrations (version) VALUES ('20161116143420');

INSERT INTO schema_migrations (version) VALUES ('20161116143524');

INSERT INTO schema_migrations (version) VALUES ('20161116143900');

INSERT INTO schema_migrations (version) VALUES ('20161117132744');

INSERT INTO schema_migrations (version) VALUES ('20161124095642');

INSERT INTO schema_migrations (version) VALUES ('20161124100101');

INSERT INTO schema_migrations (version) VALUES ('20161128080016');

INSERT INTO schema_migrations (version) VALUES ('20161128080017');

INSERT INTO schema_migrations (version) VALUES ('20161128080018');

INSERT INTO schema_migrations (version) VALUES ('20161130080018');

INSERT INTO schema_migrations (version) VALUES ('20161205131404');

INSERT INTO schema_migrations (version) VALUES ('20161223105036');

INSERT INTO schema_migrations (version) VALUES ('20161225131404');

INSERT INTO schema_migrations (version) VALUES ('20170109131405');

INSERT INTO schema_migrations (version) VALUES ('20170109131406');

INSERT INTO schema_migrations (version) VALUES ('20170109131407');

INSERT INTO schema_migrations (version) VALUES ('20170109131409');

INSERT INTO schema_migrations (version) VALUES ('20170110152512');

INSERT INTO schema_migrations (version) VALUES ('20170111082512');

INSERT INTO schema_migrations (version) VALUES ('20170130131737');

INSERT INTO schema_migrations (version) VALUES ('20170208161055');

INSERT INTO schema_migrations (version) VALUES ('20170208163547');

INSERT INTO schema_migrations (version) VALUES ('20170215132553');

INSERT INTO schema_migrations (version) VALUES ('20170217080457');

INSERT INTO schema_migrations (version) VALUES ('20170217113807');

INSERT INTO schema_migrations (version) VALUES ('20170220131404');

INSERT INTO schema_migrations (version) VALUES ('20170221100708');

INSERT INTO schema_migrations (version) VALUES ('20170221112718');

INSERT INTO schema_migrations (version) VALUES ('20170228142810');

INSERT INTO schema_migrations (version) VALUES ('20170301095532');

INSERT INTO schema_migrations (version) VALUES ('20170303200236');

INSERT INTO schema_migrations (version) VALUES ('20170303200703');

INSERT INTO schema_migrations (version) VALUES ('20170303200921');

INSERT INTO schema_migrations (version) VALUES ('20170303202644');

INSERT INTO schema_migrations (version) VALUES ('20170303203539');

INSERT INTO schema_migrations (version) VALUES ('20170310145748');

INSERT INTO schema_migrations (version) VALUES ('20170406124043');

INSERT INTO schema_migrations (version) VALUES ('20170410143944');

INSERT INTO schema_migrations (version) VALUES ('20170410154959');

INSERT INTO schema_migrations (version) VALUES ('20170412212950');

INSERT INTO schema_migrations (version) VALUES ('20170418125916');

INSERT INTO schema_migrations (version) VALUES ('20170420141436');

INSERT INTO schema_migrations (version) VALUES ('20170424153456');

INSERT INTO schema_migrations (version) VALUES ('20170505151515');

INSERT INTO schema_migrations (version) VALUES ('20170509141446');

INSERT INTO schema_migrations (version) VALUES ('20170524090229');

INSERT INTO schema_migrations (version) VALUES ('20170615163547');

INSERT INTO schema_migrations (version) VALUES ('20170622163547');

INSERT INTO schema_migrations (version) VALUES ('20170626103547');

INSERT INTO schema_migrations (version) VALUES ('20170626163547');

INSERT INTO schema_migrations (version) VALUES ('20170707103547');

INSERT INTO schema_migrations (version) VALUES ('20170711103547');

INSERT INTO schema_migrations (version) VALUES ('20170711153547');

INSERT INTO schema_migrations (version) VALUES ('20170711201405');

INSERT INTO schema_migrations (version) VALUES ('20170711223547');

INSERT INTO schema_migrations (version) VALUES ('20170711323547');

INSERT INTO schema_migrations (version) VALUES ('20170711423547');

INSERT INTO schema_migrations (version) VALUES ('20170711523547');

INSERT INTO schema_migrations (version) VALUES ('20170712163547');

INSERT INTO schema_migrations (version) VALUES ('20170714163547');

INSERT INTO schema_migrations (version) VALUES ('20170719124713');

INSERT INTO schema_migrations (version) VALUES ('20170721074915');

INSERT INTO schema_migrations (version) VALUES ('20170724150100');

INSERT INTO schema_migrations (version) VALUES ('20170731104218');

INSERT INTO schema_migrations (version) VALUES ('20170801073138');

INSERT INTO schema_migrations (version) VALUES ('20170802094212');

INSERT INTO schema_migrations (version) VALUES ('20170817032303');

INSERT INTO schema_migrations (version) VALUES ('20170906020031');

INSERT INTO schema_migrations (version) VALUES ('20170909015357');

