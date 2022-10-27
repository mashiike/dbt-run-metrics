export GIT_VER := $(shell git rev-parse --short=16 HEAD)
test-redshift:
	dbt deps
	dbt build --target redshift --full-refresh --selector default

test-postgres:
	dbt deps
	dbt build --target postgres --full-refresh --selector default

clean:
	dbt clean
