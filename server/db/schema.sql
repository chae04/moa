
    create table budget_categories (
        include_in_daily bit not null,
        is_deleted bit not null,
        order_index integer not null,
        show_on_home bit not null,
        created_at datetime(6),
        id bigint not null auto_increment,
        user_id bigint not null,
        name varchar(255) not null,
        primary key (id)
    ) engine=InnoDB;

    create table budget_ratios (
        invest_ratio integer not null,
        ratio integer not null,
        saving_ratio integer not null,
        budget_category_id bigint not null,
        created_at datetime(6),
        id bigint not null auto_increment,
        user_id bigint not null,
        apply_from varchar(255) not null,
        primary key (id)
    ) engine=InnoDB;

    create table transactions (
        amount integer not null,
        date date not null,
        budget_category_id bigint,
        created_at datetime(6),
        id bigint not null auto_increment,
        source_transaction_id bigint,
        updated_at datetime(6),
        user_id bigint not null,
        category varchar(255) not null,
        memo varchar(255),
        title varchar(255) not null,
        type varchar(255) not null,
        primary key (id)
    ) engine=InnoDB;

    create table users (
        created_at datetime(6),
        id bigint not null auto_increment,
        email varchar(255) not null,
        password varchar(255) not null,
        primary key (id)
    ) engine=InnoDB;

    alter table users 
       add constraint UK6dotkott2kjsp8vw4d0m25fb7 unique (email);

    alter table budget_categories 
       add constraint FKm5qlang2cio94kb3heobpbydc 
       foreign key (user_id) 
       references users (id);

    alter table budget_ratios 
       add constraint FKb3nf0m3ag2ya06hft2wenjpgb 
       foreign key (budget_category_id) 
       references budget_categories (id);

    alter table budget_ratios 
       add constraint FKc5rfdu80g824eafq1ii5knbme 
       foreign key (user_id) 
       references users (id);

    alter table transactions 
       add constraint FK9qs5mf433xnytjmgldm9x1ect 
       foreign key (budget_category_id) 
       references budget_categories (id);

    alter table transactions 
       add constraint FKqwv7rmvc8va8rep7piikrojds 
       foreign key (user_id) 
       references users (id);
