package EFS::WebAPI::Controller::API;

use Moose;
use MooseX::MethodAttributes;
use namespace::autoclean;
use EFS::WebAPI::Exception;
use EFS;
use EFS3::DBI;

BEGIN { extends 'Catalyst::Controller' };

with 'EFS::WebAPI::ControllerRole::API_Interface';


sub checkMetaExist {
    my $self = shift;
    my $params = validate( @_, {
        metaproj => 1,
    } );

    my $metaproj = EFS3::DBI->get_schema()->resultset( 'Metaproj' )
        ->find( { name => $params->{ metaproj } } );

    unless ( $metaproj ) {
        EFS::WebAPI::Exception->throw(
            code    => 'Invalid Metaproj',
            message => "Metaproj [$params->{metaproj}] invalid or not found",
        );
    }


}

sub regions : API {
    my ( $self, $params ) = @_;

    # no params to check

    my $region_rs = EFS3::DBI->get_schema->resultset( 'Region' )->search(
        {}, { order_by => { -asc => 'name' } },
    );

    my $regions = [];
    while ( my $region = $region_rs->next() ) {
        my $reg_struct = {
            name => $region->name(),
            attributes => {},
        };


        my $attr_rs = $region->attrs();
        while ( my $attr = $attr_rs->next() ) {
            $reg_struct->{ attributes }{ $attr->name() }
                = $attr->value();
        }
        push @$regions, $reg_struct;
    }

    return $regions;
}


sub region_details : API {
    my $self = shift;
    my $params = validate( @_, {
        region => 1,
    } );
    
    
    my $region = EFS3::DBI->get_schema->resultset( 'Region' )
        ->find( { name => $params->{ region } } );

    unless ( $region ) {
        EFS::WebAPI::Exception->throw(
            code    => 'Invalid Region',
            message => "Region [$params->{region}] invalid or not found",
        );
    }

    my $reg_struct = {
        name       => $region->name(),
        attributes => {},
        campuses   => [],
    };

    my $attr_rs = $region->attrs();
    while ( my $attr = $attr_rs->next() ) {
        $reg_struct->{ attributes }{ $attr->name() }
            = $attr->value();
    }

    my $camps_rs = $region->campuses();
    while ( my $campus = $camps_rs->next() ) {
        my $campus_struct = {
            name        => $campus->name(),
            attributes  => {},
        };

        my $attr_rs = $campus->attrs();
        while ( my $attr = $attr_rs->next() ) {
            $campus_struct->{ attributes }{ $attr->name() }
                = $attr->value();
        }

        push @{ $reg_struct->{ campuses } }, $campus_struct;
    }

    return $reg_struct;
}


sub campus_details : API {
    my $self = shift;
    my $params = validate( @_, {
        region => 1,
        campus => 1,
    } );
    
    my $campus = EFS3::DBI->get_schema()->resultset( 'Campus' )
        ->search( {
            region => $params->{ region },
            name   => $params->{ campus },
        } )->next();

    unless ( $campus ) {
        my $region = EFS3::DBI->get_schema->resultset( 'Region' )
            ->find( { name => $params->{ region } } );

        unless ( $region ) {
            EFS::WebAPI::Exception->throw(
                code    => 'Invalid Region',
                message => "Region [$params->{region}] invalid or not found",
            );
        }

        EFS::WebAPI::Exception->throw(
            code    => 'Invalid Campus',
            message => "Campus [$params->{campus}] invalid or not found within region [$params->{region}]",
        );
    }

    my $campus_struct = {
        region => $params->{ region },
        campus => $campus->name(),
        attributes => {},
        locations  => [],
    };

    my $attr_rs = $campus->attrs();
    while ( my $attr = $attr_rs->next() ) {
        $campus_struct->{ attributes }{ $attr->name() }
            = $attr->value();
    }

    my $loc_rs = $campus->locations();
    while ( my $location = $loc_rs->next() ) {
        my $loc_struct = {
            name => $location->name(),
            cells => [],
        };
        my $cell_rs = $location->cells();
        while ( my $cell = $cell_rs->next() ) {
            push @{ $loc_struct->{ cells } }, {
                name     => $cell->name(),
                celltype => $cell->celltype(),
                disabled => $cell->disabled(),
                hidden   => $cell->efshidden(),
            };
        }
        push @{ $campus_struct->{ locations } }, 
            $loc_struct;
    }


    return $campus_struct;
}

sub locations : API {
    my ( $self, $params ) = @_;

    # no params to check

    my $location_rs = EFS3::DBI->get_schema->resultset( 'Location' )->search(
        {}, { order_by => { -asc => 'name' } },
    );

    my $locations = [];
    while ( my $location = $location_rs->next() ) {
        my $reg_struct = {
            name => $location->name(),
            region => $location->region(),
            campus => $location->campus(),
            attributes => {},
        };


        my $attr_rs = $location->attrs();
        while ( my $attr = $attr_rs->next() ) {
            $reg_struct->{ attributes }{ $attr->name() }
                = $attr->value();
        }
        push @$locations, $reg_struct;
    }

    return $locations;
}

sub metaprojs : API {
    my $self = shift;
    my $params = validate( @_, {
        rows            => 0,
        page            => 0,
        with_file_stats => 0,
    } );

    my $page = $params->{page} || 1;
    my $rows = $params->{rows} || 15;
    
    my $search_attribs = {
        order_by => { -asc => 'name' },
    };

    unless ( $rows eq 'all' ) {
        $search_attribs->{ page } = $page;
        $search_attribs->{ rows } = $rows;
    }

    my $resultset = EFS3::DBI->get_schema()->resultset( 'Metaproj' )->search(
        {}, $search_attribs,
    );

    my $struct = {
        rows      => $rows,
        metaprojs => [],
    };

    if ( $rows eq 'all' ) {
        my $count = EFS3::DBI->get_schema()->resultset( 'Metaproj' )->count();
        $struct->{ total_count } = $count;
    }
    else {
        my $pager = $resultset->pager();
        $struct->{ page }      = $page;
        $struct->{ last_page } = $pager->last_page();
        $struct->{ total_count } = $pager->total_entries();
    }

    while ( my $metaproj = $resultset->next() ) {
        push @{ $struct->{ metaprojs } },
            $self->mpresult2struct(
                metaproj => $metaproj,
                with_file_stats => $params->{ with_file_stats },
            );
    }

    return $struct;
}


sub metaproj_details : API {
    my $self = shift;
    my $params = validate( @_, {
        metaproj => 1,
    } );
    
    my $metaproj = EFS3::DBI->get_schema()->resultset( 'Metaproj' )
        ->find( { name => $params->{ metaproj } } );

    unless ( $metaproj ) {
        EFS::WebAPI::Exception->throw(
            code    => 'Invalid Metaproj',
            message => "Metaproj [$params->{metaproj}] invalid or not found",
        );
    }

    return $self->mpresult2struct(
        metaproj             => $metaproj, 
        with_file_stats      => 1,
        with_attrs_and_users => 1,
    );
}


sub metrics : API {
    my ( $self, $params ) = @_;

    # no params to check

    my $efsservers_count = EFS3::DBI->get_schema->resultset( 'Efsserver' )->count();
    my $metaprojects_count = EFS3::DBI->get_schema->resultset( 'Metaproj' )->count();
    my $projects_count = EFS3::DBI->get_schema->resultset( 'Project' )->count();
    my $releases_count = EFS3::DBI->get_schema->resultset( 'Release' )->count();
    my $releaselinks_count = EFS3::DBI->get_schema->resultset( 'Releaselink' )->count();
    my $users_count = EFS3::DBI->get_schema->resultset( 'History' )->search(
        {}, { select => [{ count => { distinct => 'authuser' } }], as => ['count']});
    

    my $metric_struct = {
        efsservers => $efsservers_count,
        metaprojects => $metaprojects_count,
        projects => $projects_count,
        releases => $releases_count,
        releaselinks => $releaselinks_count,
        users => $users_count
    }

    return $metric_struct;
}


sub projects : API {
    my $self = shift;
    my $params = validate( @_, {
        metaproj        => 1,
        rows            => 0,
        page            => 0,
        with_file_stats => 0,
    } );
    

    my $page = $params->{page} || 1;
    my $rows = $params->{rows} || 15;
    
    my $search_attribs = {
        order_by => { -asc => 'name' },
    };
    unless ( $rows eq 'all' ) {
        $search_attribs->{ page } = $page;
        $search_attribs->{ rows } = $rows;
    }


    my $proj_rs = EFS3::DBI->get_schema->resultset( 'Project' )->search(
        { metaproj => $params->{ metaproj } },
        $search_attribs
    );

    my $struct = {
        metaproj => $params->{ metaproj },
        projects => [],
        rows => $rows,
    };

    if ( $rows eq 'all' ) {
        my $count = EFS3::DBI->get_schema->resultset( 'Project' )->search(
            { metaproj => $params->{ metaproj } },
        )->count();
        $struct->{ total_count } = $count;
    }
    else {
        my $pager = $proj_rs->pager();
        $struct->{ page }      = $page;
        $struct->{ last_page } = $pager->last_page();
        $struct->{ total_count } = $pager->total_entries(),
    }


    my $count = 0;
    while ( my $project = $proj_rs->next() ) {
        $count++;
        push @{ $struct->{ projects } }, $self->projectresult2struct( 
            project => $project,
            with_file_stats => $params->{ with_file_stats },
        );
    }

    # if we found no projects, hit the db one more time, 
    # to make sure that the user passed in a valid metaproj
    unless ( $count ) {
        my $metaproj = EFS3::DBI->get_schema()->resultset( 'Metaproj' )
            ->find( { name => $params->{ metaproj } } );

        unless ( $metaproj ) {
            EFS::WebAPI::Exception->throw(
                code    => 'Invalid Metaproj',
                message => "Metaproj [$params->{metaproj}] invalid or not found",
            );
        }
    }

    return $struct;
}


sub project_details : API {
    my $self = shift;
    my $params = validate( @_, {
        metaproj => 1,
        project  => 1,
    } );
    
    my $project = EFS3::DBI->get_schema()->resultset( 'Project' )
        ->find( {
            metaproj => $params->{ metaproj },
            name => $params->{ project },
        } );

    unless ( $project ) {
        EFS::WebAPI::Exception->throw(
            code    => 'Invalid Project',
            message => "Project [$params->{project}] invalid or not found",
        );
    }

    return $self->projectresult2struct(
        project           => $project,
        with_file_stats   => 1,
        with_release_info => 1,
    );
}

sub releases : API {
    my $self = shift;
    my $params = validate( @_, {
        metaproj        => 1,
        project         => 1,
        rows            => 0,
        page            => 0,
        with_file_stats => 0,
    } );

    my $mymeta = $params->{ metaproj };
    my $myproj = $params->{ project };

    my $page = $params->{page} || 1;
    my $rows = $params->{rows} || 15;

    my $search_attribs = {
        order_by => { -asc => 'name' },
    };
    unless ( $rows eq 'all' ) {
        $search_attribs->{ page } = $page;
        $search_attribs->{ rows } = $rows;
    }

    my $rel_rs = EFS3::DBI->get_schema->resultset( 'Release' )->search(
        {
            metaproj => $mymeta,
            project  => $myproj,
        },
        $search_attribs
    );

    my $struct = {
        metaproj => $mymeta,
        project  => $myproj,
        releases => [],
        rows     => $rows,
    };

    if ( $rows eq 'all' ) {
        my $count = EFS3::DBI->get_schema->resultset( 'Release' )->search(
            { metaproj => $mymeta,
              project  => $myproj, },
        )->count();
        $struct->{ total_count } = $count;
    }
    else {
        my $pager = $rel_rs->pager();
        $struct->{ page }      = $page;
        $struct->{ last_page } = $pager->last_page();
        $struct->{ total_count } = $pager->total_entries(),
    }

    my $count = 0;
    while ( my $release = $rel_rs->next() ) {
        $count++;
        push @{ $struct->{ releases } }, $self->releaseresult2struct(
            release => $release,
            with_file_stats => $params->{ with_file_stats },
        );
    }

    # if we found no projects, hit the db one more time,
    # to make sure that the user passed in a valid metaproj
    unless ( $count ) {
        my $metaproj = EFS3::DBI->get_schema()->resultset( 'Metaproj' )
            ->find( { name => $mymeta } );

        unless ( $metaproj ) {
            EFS::WebAPI::Exception->throw(
                code    => 'Invalid Metaproj',
                message => "Metaproj [$mymeta] invalid or not found",
            );
        }

        # do the same check on the project
        # we are here because the metaproj was legit
        my $project = EFS3::DBI->get_schema()->resultset( 'Project' )
            ->find( {
                metaproj => $mymeta,
                name => $myproj,
            } );

        unless ( $project ) {
            EFS::WebAPI::Exception->throw(
                code    => 'Invalid Project',
                message => "Project [$myproj] invalid or not found",
            );
        }
    }

    return $struct;
}

sub release_details : API {
    my $self = shift;
    my $params = validate( @_, {
        metaproj => 1,
        project  => 1,
        release  => 1,
    } );

    my $release = EFS3::DBI->get_schema()->resultset( 'Release' )
        ->find( {
            metaproj => $params->{ metaproj },
            project  => $params->{ project },
            name     => $params->{ release },
        } );

    unless ( $release ) {
        EFS::WebAPI::Exception->throw(
            code    => 'Invalid Release',
            message => "Release [$params->{metaproj}/$params->{project}]/[$params->{release}] invalid or not found",
        );
    }

    return $self->releaseresult2struct (
        release           => $release,
        with_file_stats   => 1,
        with_release_info => 1,
    );
}


sub search : API {
    my $self = shift;
    my $params = validate( @_, {
        q => 1, 
        page => { 
            optional => 1,
            depends  => [ 'record_type' ],
        },
        rows => 0,
        record_type => 0,
    } );

    my $rows = $params->{ rows } // 10;
    my $page = $params->{ page } // 1;
    my $search_attribs = {
        order_by => { -asc => 'name' },
        page => $page,
        rows => $rows,
    };

    my @query_words = split /\s+/, $params->{ q };
    my @search;
    for my $word ( map lc, @query_words ) {
        push @search, "lower(name) like '%%$word%%'";
    }
    my $search = join ' AND ', @search;
    $search_attribs-> { where } = $search;

    my $struct = {
    };

    if ( $params->{ record_type } eq '' or $params->{ record_type } eq 'metaproj' ) {
        my $metaproj_rs = EFS3::DBI->get_schema->resultset( 'Metaproj' )->search(
            {}, $search_attribs
        );

        my $pager = $metaproj_rs->pager();
        $struct->{ metaproj_page }{ page }      = $page;
        $struct->{ metaproj_page }{ last_page } = $pager->last_page();
        $struct->{ metaproj_page }{ total_count } = $pager->total_entries();

        while ( my $metaproj = $metaproj_rs->next() ) {
            push @{ $struct->{ metaprojs } }, $self->mpresult2struct( 
                metaproj => $metaproj,
                with_file_stats => 1
            );
        }
    }

    if ( $params->{ record_type } eq '' or $params->{ record_type } eq 'project' ) {
        my $project_rs = EFS3::DBI->get_schema->resultset( 'Project' )->search(
            {}, $search_attribs
        );

        my $pager = $project_rs->pager();
        $struct->{ project_page }{ page }      = $page;
        $struct->{ project_page }{ last_page } = $pager->last_page();
        $struct->{ project_page }{ total_count } = $pager->total_entries();

        while ( my $project = $project_rs->next() ) {
            push @{ $struct->{ projects } }, $self->projectresult2struct( 
                project => $project,
                with_file_stats => 1
            );
        }
    }

    return $struct;
}

# XXX this could be much cleaner with views defined in the database 
sub mpresult2struct {
    my ( $self, %args ) = @_;
    my $metaproj = $args{ metaproj };

    my $meta_struct = { 
        name       => $metaproj->name(),
        username   => $metaproj->username(),
        groupname  => $metaproj->groupname(),
    };

    if ( $args{ with_attrs_and_users } ) {
        $meta_struct->{ attributes } = {};
        $meta_struct->{ userrights } = [];

        my $attrs_rs = $metaproj->attrs();
        while ( my $attr = $attrs_rs->next() ) {
            $meta_struct->{ attributes }{ $attr->name() }
                = $attr->value();
        }

        my $user_rs = $metaproj->userrights();
        while ( my $userright = $user_rs->next() ) {
            push @{ $meta_struct->{ userrights } }, {
                role     => $userright->role(),
                username => $userright->username(),
            };
        }
    }

    if ( $args{ with_file_stats } ) {
        my $projects_count = EFS3::DBI->get_schema->resultset( 'Project' )->search(
            { metaproj => $metaproj },
        )->count();
        $meta_struct->{ projects_count } = $projects_count;

        my $counts_struct = $self->get_install_stats(
            metaproj => $metaproj->name(),
        );

        $meta_struct->{ $_ } = $counts_struct->{ $_ }
            for keys %$counts_struct;
    }

    return $meta_struct;
}

# XXX this could be much cleaner with views defined in the database 
sub projectresult2struct {
    my ( $self, %args ) = @_;
    my $project = $args{ project };

    my $proj_struct = {
        metaproj => $project->metaproj->name(),
        project  => $project->name(),
        cell     => $project->cell->name(),
    };

    if ( $args{ with_release_info } ) {
        $proj_struct->{ releaselinks }    = [];
        $proj_struct->{ active_releases } = [];

        my $ra_rs = $project->releasealiases();
        while ( my $releasealias = $ra_rs->next() ) {
            # note: in EFS 2.x, it's releaselink; in 3.x it's releasealias
            push @{ $proj_struct->{ releaselinks } }, 
                {
                    link   => $releasealias->name(),
                    target => $releasealias->target->name(),
                };
        }

        my $r_rs = $project->releases();
        while ( my $release = $r_rs->next() ) {
            push @{ $proj_struct->{ active_releases } }, 
                {
                    release => $release->name(),
                    stage   => $release->stage(),
                };
        }
    }

    if ( $args{ with_file_stats } ) {
        my $counts_struct = $self->get_install_stats(
            metaproj => $project->metaproj->name(),
            project  => $project->name(),
        );

        $proj_struct->{ $_ } = $counts_struct->{ $_ }
            for keys %$counts_struct;
    }
    
    return $proj_struct;
}

# XXX this could be much cleaner with views defined in the database 
sub releaseresult2struct {
    my ( $self, %args ) = @_;
    my $release = $args{ release };

    my $release_struct = {
        metaproj => $release->metaproj(),
        project  => $release->project()->name(),
        name  => $release->name(),
        cell     => $release->cell(),
        locked   => $release->locked(),
        stage    => $release->stage(),
    };

    if ( $args{ with_release_info } ) {
        $release_struct->{ installs }    = [];
        $release_struct->{ runtime_release_dependencies } = [];

        my $ra_rs = $release->installs();
        while ( my $install = $ra_rs->next() ) {
            # note: in EFS 2.x, it's releaselink; in 3.x it's releasealias
            push @{ $release_struct->{ installs } }, {
                metaproj  => $install->metaproj,
                project   => $install->project,
                release   => $install->efsrelease()->name(),
                name      => $install->name,
                spaceused => $install->spaceused,
                filecount => $install->filecount,
                dircount  => $install->dircount,
                linkcount => $install->linkcount,
            };
        }
	
        my $dep_rel = $release->releases();

        while ( my $depr = $dep_rel->next() ) {
            push @{ $release_struct->{ runtime_release_dependencies } },
            {
                metaproj => $depr->metaproj,
                project => $depr->project,
                efsrelease => $depr->efsrelease,
                dependent_metaproj => $depr->dependent_metaproj,
                dependent_project => $depr->dependent_project,
                dependent_release => $depr->dependent_release()->name(),
                type => $depr->type,
            };
        }
    }

    if ( $args{ with_file_stats } ) {
        my $counts_struct = $self->get_install_stats(
            metaproj => $release->metaproj(),
            project  => $release->project()->name(),
            release  => $release->name(),
        );

        $release_struct->{ $_ } = $counts_struct->{ $_ }
            for keys %$counts_struct;
    }

    return $release_struct;
}


sub get_install_stats {
    my ( $self, %install_searches ) = @_;

    # %install_searches are key => value pairs to match
    # the installs on. Allowable keys are:
    #   metaproj
    #   project
    #   release
    # 
    # Any key provided requires all keys above it in the list.


    my $installs_count_rs = EFS3::DBI->get_schema()
        ->resultset( 'Install' )->search(
            \%install_searches,
            {
                select => [
                    { sum => 'filecount' },
                    { sum => 'dircount'  },
                    { sum => 'spaceused' },
                    { sum => 'linkcount' },
                ],
                as     => [ qw(
                    total_filecount
                    total_dircount
                    total_spaceused
                    total_linkcount
                ) ],
            }
        );

    my $counts = $installs_count_rs->first();
    my $counts_struct = {};

    $counts_struct->{ filecount } =
        $counts->get_column( 'total_filecount' );
    $counts_struct->{ dircount } =
        $counts->get_column( 'total_dircount' );
    $counts_struct->{ spaceused } =
        $counts->get_column( 'total_spaceused' );
    $counts_struct->{ spaceused_human } = 
        EFS::DBI->size_shorthand( $counts_struct->{ spaceused } );
    $counts_struct->{ linkcount } =
        $counts->get_column( 'total_linkcount' );
    
    return $counts_struct;
}



1;
