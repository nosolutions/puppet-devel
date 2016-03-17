## Manual testing before a release

### rake tests

- destroy all boxes with vagrant destroy -f
- boot the standard centos7 box
- login into centos7
- make sure you are in /vagrant
- run rake config
- run make clone -> should clone sitemodule (puppet/)
- run make module and create a new module
  - check local repo
  - check gitlab
  - check jenkins jobs
- modify local module
- push
  - jenkins jobs are running?
- rake release the module
- rake deploy the module
- rake sitemodule
  - check sitemodule is there

### run rspecs

- touch .puppetdeveldevel
- vagrant provision centos7
- rake spec
