requires 'perl', '5.008004';
requires 'parent';
requires 'Kossy', '0.38';
requires 'Kossy::Validator', '0.01';
requires 'Object::Container::Exporter', '0.03';
requires 'Plack::Middleware::Debug', '0.16';
requires 'Plack::Session::Store::File', '0.24';
requires 'Teng', '0.25';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

