package GPB;
use Dancer2;

use DBI;
my $dbh = DBI->connect(
    'DBI:mysql:database=gpb;host=localhost', 'gpb', 'passwd',
    { RaiseError => 1 },
);

get '/' => sub {

    my $limit   = query_parameters->get('limit') || 100;
    my $address = query_parameters->get('address');

    my $logs = $dbh->selectall_arrayref(q(
        SELECT
            log_id, created, '' AS id, int_id, str, address
        FROM log
            WHERE
                int_id IN( SELECT DISTINCT int_id FROM log WHERE address = ? )
                AND ( address = ? OR address IS NULL )
        UNION
        SELECT
            log_id, created, id, int_id, str, '' AS address
        FROM message
        WHERE int_id IN( SELECT DISTINCT int_id FROM log WHERE address = ? )
        ORDER BY int_id, log_id
        LIMIT ?
        ), { Slice => {} },
        ( map { $address } 1..3 ),
        $limit + 1,
    );

    template 'gpb.tt' => {
        address => $address,
        logs    => [ splice( @$logs, 0, $limit )],
        more    => scalar @$logs,
    };
};

true;
