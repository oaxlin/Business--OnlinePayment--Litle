package Business::OnlinePayment::Litle::UpdaterResponse;
use strict;
use warnings;

# ABSTRACT: Business::OnlinePayment::Litle::UpdaterResponse
# VERSION

=head1 NAME

Business::OnlinePayment::Litle::UpdaterResponse

=head2 METHODS

Additional methods created by this package.

=over

=item new

Create a new updater response object.

=back

=cut

sub new{
    my ($class, $args) = @_;
    my $self = bless $args, $class;

    $self->_build_subs(
            qw( cust_id order_number invoice_number batch_date result_code
            new_card_token old_cardnum old_type old_expdate
            error_message is_success type is_updated new_cardnum new_expdate new_type));

    $self->order_number( $args->{'litleTxnId'});
    $self->invoice_number( $args->{'orderId'});
    $self->batch_date( $args->{'responseTime'});
    $self->result_code( $args->{'response'});
    $self->error_message( $args->{'message'});
    $self->cust_id( $args->{'customerId'});
    $self->type( $args->{'originalCard'} ? 'confirm' : 'auth' );
    $self->is_updated(0);
    if ( $args->{'originalCard'} ) {
        $self->old_cardnum( $args->{'originalCard'}->{'number'} );
        $self->old_type( $args->{'originalCard'}->{'type'} );
        $self->old_expdate( $args->{'originalCard'}->{'expDate'} );
    }
    if ( $self->type eq 'confirm' ){
        if ( $args->{'updatedToken'} ) {
            $self->new_card_token( $args->{'updatedToken'}->{'litleToken'} );
            $self->new_type( $args->{'updatedToken'}->{'type'} );
            $self->new_expdate( $args->{'updatedToken'}->{'expDate'} );
            $self->is_updated(1);
        } elsif ( $args->{'updatedCard'}->{'number'} && $args->{'updatedCard'}->{'number'} ne 'N/A' ) {
            $self->new_cardnum( $args->{'updatedCard'}->{'number'} );
            $self->new_type( $args->{'updatedCard'}->{'type'} );
            $self->new_expdate( $args->{'updatedCard'}->{'expDate'} );
            $self->is_updated(1);
        }
    }

    $self->is_success(1);
    return $self;
}

sub _build_subs {
    my $self = shift;

    foreach(@_) {
        next if($self->can($_));
        eval "sub $_ { my \$self = shift; if(\@_) { \$self->{$_} = shift; } return \$self->{$_}; }"; ## no critic
    }
}

1;
