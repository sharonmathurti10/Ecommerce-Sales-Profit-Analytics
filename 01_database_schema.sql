--
-- PostgreSQL database dump
--

\restrict 5clQrjxvE9ojfmjKD0fj6bPT6dM7OXmd08aYBvGe33oWiV26wrxOJZnhIdMXqH5

-- Dumped from database version 17.7
-- Dumped by pg_dump version 17.7

-- Started on 2026-06-30 14:36:59

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 4954 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 16759)
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    customer_id text,
    customer_name text,
    segment text,
    country text,
    city text,
    state text,
    postal_code text,
    region text
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16778)
-- Name: customers_clean; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers_clean (
    customer_id text,
    customer_name text,
    region text
);


ALTER TABLE public.customers_clean OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16722)
-- Name: e_commerce; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.e_commerce (
    row_id text,
    order_id text,
    order_date text,
    ship_date text,
    ship_mode text,
    customer_id text,
    customer_name text,
    segment text,
    country text,
    city text,
    state text,
    postal_code text,
    region text,
    product_id text,
    category text,
    sub_category text,
    product_name text,
    sales text,
    quantity text,
    discount text,
    profit text
);


ALTER TABLE public.e_commerce OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16744)
-- Name: e_commerce_clean; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.e_commerce_clean (
    row_id integer,
    order_id text,
    order_date date,
    ship_date date,
    ship_mode text,
    customer_id text,
    customer_name text,
    segment text,
    country text,
    city text,
    state text,
    postal_code text,
    region text,
    product_id text,
    category text,
    sub_category text,
    product_name text,
    sales numeric,
    quantity integer,
    discount numeric,
    profit numeric
);


ALTER TABLE public.e_commerce_clean OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16773)
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    row_id integer,
    order_id text,
    order_date date,
    ship_date date,
    ship_mode text,
    customer_id text,
    product_id text,
    sales numeric,
    quantity integer,
    discount numeric,
    profit numeric
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16767)
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    product_id text,
    product_name text,
    category text,
    sub_category text
);


ALTER TABLE public.products OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16783)
-- Name: products_clean; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products_clean (
    product_id text,
    product_name text,
    category text
);


ALTER TABLE public.products_clean OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16716)
-- Name: test_import; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.test_import (
    data text
);


ALTER TABLE public.test_import OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16797)
-- Name: vw_category_performance; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_category_performance AS
 SELECT p.category,
    sum(o.sales) AS total_sales,
    sum(o.profit) AS total_profit,
    round(((sum(o.profit) / NULLIF(sum(o.sales), (0)::numeric)) * (100)::numeric), 2) AS profit_margin_pct,
    count(DISTINCT o.order_id) AS total_orders
   FROM (public.orders o
     JOIN public.products_clean p ON ((o.product_id = p.product_id)))
  GROUP BY p.category;


ALTER VIEW public.vw_category_performance OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16812)
-- Name: vw_customer_segments; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_customer_segments AS
 WITH customer_data AS (
         SELECT o.customer_id,
            c.customer_name,
            sum(o.sales) AS total_spent,
            count(DISTINCT o.order_id) AS total_orders,
            max(o.order_date) AS last_order_date
           FROM (public.orders o
             JOIN public.customers_clean c ON ((o.customer_id = c.customer_id)))
          GROUP BY o.customer_id, c.customer_name
        )
 SELECT customer_id,
    customer_name,
    total_spent,
    total_orders,
    last_order_date,
        CASE
            WHEN ((total_spent >= (5000)::numeric) AND (total_orders >= 5)) THEN 'High Value'::text
            WHEN (total_spent >= (2000)::numeric) THEN 'Medium Value'::text
            ELSE 'Low Value'::text
        END AS customer_segment
   FROM customer_data;


ALTER VIEW public.vw_customer_segments OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16788)
-- Name: vw_kpi_summary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_kpi_summary AS
 SELECT sum(sales) AS total_sales,
    sum(profit) AS total_profit,
    count(DISTINCT order_id) AS total_orders,
    count(DISTINCT customer_id) AS unique_customers,
    count(DISTINCT product_id) AS unique_products,
    round(avg(sales), 2) AS avg_order_value,
    round(((sum(profit) / NULLIF(sum(sales), (0)::numeric)) * (100)::numeric), 2) AS profit_margin_pct
   FROM public.orders;


ALTER VIEW public.vw_kpi_summary OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16792)
-- Name: vw_monthly_performance; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_monthly_performance AS
 WITH monthly_data AS (
         SELECT (date_trunc('month'::text, (orders.order_date)::timestamp with time zone))::date AS month,
            sum(orders.sales) AS total_sales,
            sum(orders.profit) AS total_profit,
            count(DISTINCT orders.order_id) AS total_orders
           FROM public.orders
          GROUP BY (date_trunc('month'::text, (orders.order_date)::timestamp with time zone))
        )
 SELECT month,
    total_sales,
    total_profit,
    total_orders,
    lag(total_sales) OVER (ORDER BY month) AS pervious_month_sales,
    round((((total_sales - lag(total_sales) OVER (ORDER BY month)) / NULLIF(lag(total_sales) OVER (ORDER BY month), (0)::numeric)) * (100)::numeric), 2) AS growth_pct
   FROM monthly_data;


ALTER VIEW public.vw_monthly_performance OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16807)
-- Name: vw_product_performance; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_product_performance AS
 SELECT o.product_id,
    p.product_name,
    p.category,
    sum(o.sales) AS total_sales,
    sum(o.profit) AS total_profit,
    round(avg(o.discount), 2) AS avg_discount,
    count(*) AS order_count,
    round(((sum(o.profit) / NULLIF(sum(o.sales), (0)::numeric)) * (100)::numeric), 2) AS profit_margin_pct
   FROM (public.orders o
     JOIN public.products_clean p ON ((o.product_id = p.product_id)))
  GROUP BY o.product_id, p.product_name, p.category;


ALTER VIEW public.vw_product_performance OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16802)
-- Name: vw_region_performance; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_region_performance AS
 SELECT COALESCE(NULLIF(TRIM(BOTH FROM c.region), ''::text), 'Unknown'::text) AS region,
    sum(o.sales) AS total_sales,
    sum(o.profit) AS total_profit,
    round(((sum(o.profit) / NULLIF(sum(o.sales), (0)::numeric)) * (100)::numeric), 2) AS profit_margin_pct,
    count(DISTINCT o.order_id) AS total_orders
   FROM (public.orders o
     JOIN public.customers_clean c ON ((o.customer_id = c.customer_id)))
  GROUP BY COALESCE(NULLIF(TRIM(BOTH FROM c.region), ''::text), 'Unknown'::text);


ALTER VIEW public.vw_region_performance OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16822)
-- Name: vw_sales_data; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_sales_data AS
 SELECT o.order_id,
    o.order_date,
    o.customer_id,
    c.customer_name,
    o.product_id,
    p.product_name,
    p.category,
    c.region,
    o.sales,
    o.profit,
    o.discount,
    o.quantity
   FROM ((public.orders o
     JOIN public.customers_clean c ON ((o.customer_id = c.customer_id)))
     JOIN public.products_clean p ON ((o.product_id = p.product_id)));


ALTER VIEW public.vw_sales_data OWNER TO postgres;

-- Completed on 2026-06-30 14:37:01

--
-- PostgreSQL database dump complete
--

\unrestrict 5clQrjxvE9ojfmjKD0fj6bPT6dM7OXmd08aYBvGe33oWiV26wrxOJZnhIdMXqH5

