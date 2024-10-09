# Changelog

## v1.3.5 - Oct 9, 2024

- Silence ActiveRecord output while running specs. Clean green dots! (@eeklund, @dlagerro)
- Fix growing indentation issue in schema.rb after `schema:dump`/`schema:load` (@eeklund, @dlagerro)

## v1.3.4 - Jul 22, 2024

- Fixes a syntax issue in pre-3.1 rubies
- Fixes SchemaDumper error when all view objects aren't present in Oracle's user_dependencies
- Reduce git churn in schema.rb by ordering views before they're handed to SchemaDumper
- Strip newlines and trailing semicolons from view definitions

## v1.3.3  - Jul 18, 2024

- Fixes an issue with dependency sorting where mviews will sometimes be classified as a tables in user_dependencies (@whit0694)

## v1.3.2 - Jul 3, 2024

- Fixes a bug in the dependency-ordered views logic when Scenic views depend on external objects (@whit0694)

## v1.3.1 - Jul 3, 2024

- Ensures views in schema.rb are correctly ordered based on dependencies

## v1.3.0 - Mar 29, 2024

- Update to scenic version 1.8.0
- Adds support for the #populated? model method

## v1.2.2 - Apr 27, 2023

- This fixes the botched publishing of 1.2.1 (#14).
- The 1.2.1 gem file that was published to rubygems.org didn't contain any source code in the tarball. It was yanked and replaced with 1.2.2.

## v1.2.1 - Apr 20, 2023

- Fixes a bug where update_view fails on materialized views (#13)

## v1.2.0 - Dec 16, 2022

- Update to scenic version 1.7.0
- Update Oracle docker container to 21 XE for testing and local development

## v1.1.1 - Sep 10, 2021

- Fixes issue with schema dumping in pre-1.7.0 versions of activerecord-oracle_enhanced-adapter.

## v1.1.0 - Apr 23, 2021

- Added support for unpopulated materialized views (build deferrred) via scenic's no_data option.
- Move CI from Travis CI to Github Actions.

## v1.0.3 - Apr 22, 2021

- Update scenic dependency to 1.5.4 to provide support for Ruby 3

## v1.0.2 - May 11, 2020

- Remove ruby-oci as a direct dependency for jruby users (it was moved to a development dependency)
- Drop ruby 2.4 from the CI matrix. 2.4 is no longer supported.

## v1.0.1 - Apr 7, 2020

- Update rake development dependency to address CVE-2020-8130
- Default to docker/docker-compose for development and specs

## v1.0.0 - Nov 25, 2018

- This release adds cascading materialized view refreshes.

## v0.2.0 Pre-release - Oct 24, 2018

- Initial release with feature parity with Scenic::Adapters::Postgres with the exception of cascading materialized view refreshes.
