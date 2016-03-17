class { 'puppetvagrant::jenkins': }
class { 'puppetvagrant::gitlab': }

anchor { 'devel::begin': } ->
Class['puppetvagrant::jenkins'] ->
Class['puppetvagrant::gitlab']
anchor { 'devel::end': }
