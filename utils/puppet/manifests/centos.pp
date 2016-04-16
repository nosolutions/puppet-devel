Exec { timeout => 600 }

class { 'puppetvagrant::gnupg': } ->
class { 'puppetvagrant::proxy': } ->
class { 'puppetvagrant::packages': } ->
class { 'puppetvagrant::rvm': } ->
class { 'puppetvagrant::setup': }
