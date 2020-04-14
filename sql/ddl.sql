-- Table: public.author

-- DROP TABLE public.author;

CREATE TABLE public.author
(
    id integer NOT NULL,
    name character varying(30) COLLATE pg_catalog."default",
    alt_names character varying(30)[] COLLATE pg_catalog."default",
    birth_date character varying(20) COLLATE pg_catalog."default",
    CONSTRAINT author_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE public.author
    OWNER to postgres;

-- Table: public.book

-- DROP TABLE public.book;

CREATE TABLE public.book
(
    id integer NOT NULL,
    publisher_id integer NOT NULL,
    title character varying(30) COLLATE pg_catalog."default",
    isbn character varying(30) COLLATE pg_catalog."default",
    genre character varying(20) COLLATE pg_catalog."default",
    num_pages integer,
    date_published character varying(20) COLLATE pg_catalog."default",
    price numeric(5,2),
    stock_count integer,
    pub_percentage numeric(5,2),
    pub_price numeric(5,2),
    CONSTRAINT book_pkey PRIMARY KEY (id),
    CONSTRAINT book_publisher_id_fkey FOREIGN KEY (publisher_id)
        REFERENCES public.publisher (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public.book
    OWNER to postgres;

-- Trigger: auto_order_books

-- DROP TRIGGER auto_order_books ON public.book;

-- trigger - explained in more detail in trigger.sql
CREATE TRIGGER auto_order_books
    AFTER UPDATE 
    ON public.book
    FOR EACH ROW
    EXECUTE PROCEDURE public.auto_order_books_function();


-- Table: public.book_order

-- DROP TABLE public.book_order;

CREATE TABLE public.book_order
(
    book_id integer NOT NULL,
    order_id integer NOT NULL,
    quantity integer,
    is_restock boolean,
    CONSTRAINT book_order_pkey PRIMARY KEY (book_id, order_id),
    CONSTRAINT book_order_book_id_fkey FOREIGN KEY (book_id)
        REFERENCES public.book (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT book_order_order_id_fkey FOREIGN KEY (order_id)
        REFERENCES public.orders (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE public.book_order
    OWNER to postgres;

-- Table: public.orders

-- DROP TABLE public.orders;

CREATE TABLE public.orders
(
    id integer NOT NULL,
    date character varying(20) COLLATE pg_catalog."default" NOT NULL,
    user_id integer NOT NULL,
    CONSTRAINT order_pkey PRIMARY KEY (id),
    CONSTRAINT user_id_orders_fkey FOREIGN KEY (user_id)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE public.orders
    OWNER to postgres;

-- Table: public.pub_phone_number

-- DROP TABLE public.pub_phone_number;

CREATE TABLE public.pub_phone_number
(
    publisher_id integer NOT NULL,
    phone_number character varying(15) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT pub_phone_number_pkey PRIMARY KEY (publisher_id, phone_number),
    CONSTRAINT pub_phone_number_publisher_id_fkey FOREIGN KEY (publisher_id)
        REFERENCES public.publisher (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public.pub_phone_number
    OWNER to postgres;

-- Table: public.publisher

-- DROP TABLE public.publisher;

CREATE TABLE public.publisher
(
    id integer NOT NULL,
    name character varying(30) COLLATE pg_catalog."default",
    building_number integer,
    street_name character varying(30) COLLATE pg_catalog."default",
    city character varying(30) COLLATE pg_catalog."default",
    province character varying(30) COLLATE pg_catalog."default",
    country character varying(30) COLLATE pg_catalog."default",
    postal_code character varying(30) COLLATE pg_catalog."default",
    email_address character varying(30) COLLATE pg_catalog."default",
    bank_account_num character varying(30) COLLATE pg_catalog."default",
    bank_name character varying(30) COLLATE pg_catalog."default",
    CONSTRAINT publisher_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE public.publisher
    OWNER to postgres;

-- Table: public.stock

-- DROP TABLE public.stock;

CREATE TABLE public.stock
(
    id integer NOT NULL,
    book_id integer NOT NULL,
    CONSTRAINT stock_pkey PRIMARY KEY (id),
    CONSTRAINT stock_book_id_fkey FOREIGN KEY (book_id)
        REFERENCES public.book (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public.stock
    OWNER to postgres;

-- Table: public.user_phone_number

-- DROP TABLE public.user_phone_number;

CREATE TABLE public.user_phone_number
(
    user_id integer NOT NULL,
    phone_number character varying(20) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT user_phone_number_pkey PRIMARY KEY (user_id, phone_number),
    CONSTRAINT user_phone_number_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public.user_phone_number
    OWNER to postgres;

-- Table: public.users

-- DROP TABLE public.users;

CREATE TABLE public.users
(
    id integer NOT NULL,
    name character varying(30) COLLATE pg_catalog."default",
    email character varying(30) COLLATE pg_catalog."default",
    billing_building_number integer,
    billing_street_name character varying(30) COLLATE pg_catalog."default",
    billing_postal_code character varying(10) COLLATE pg_catalog."default",
    billing_city character varying(30) COLLATE pg_catalog."default",
    billing_province character varying(20) COLLATE pg_catalog."default",
    billing_country character varying(20) COLLATE pg_catalog."default",
    card_type character varying(20) COLLATE pg_catalog."default",
    card_number character varying(30) COLLATE pg_catalog."default",
    shipping_building_number integer,
    shipping_street_name character varying(30) COLLATE pg_catalog."default",
    shipping_postal_code character varying(10) COLLATE pg_catalog."default",
    shipping_city character varying(20) COLLATE pg_catalog."default",
    shipping_province character varying(20) COLLATE pg_catalog."default",
    shipping_country character varying(20) COLLATE pg_catalog."default",
    is_owner boolean,
    password character varying(30) COLLATE pg_catalog."default",
    CONSTRAINT user_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE public.users
    OWNER to postgres;

-- Table: public.writes

-- DROP TABLE public.writes;

CREATE TABLE public.writes
(
    author_id integer NOT NULL,
    book_id integer NOT NULL,
    CONSTRAINT writes_pkey PRIMARY KEY (author_id, book_id),
    CONSTRAINT writes_author_id_fkey FOREIGN KEY (author_id)
        REFERENCES public.author (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT writes_book_id_fkey FOREIGN KEY (book_id)
        REFERENCES public.book (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE public.writes
    OWNER to postgres;