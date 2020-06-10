# README: http://makefiletutorial.com
TARGET_PATH   = /src/app
VOLUME_PATH   = $(shell pwd):$(TARGET_PATH)
RUBY_IMAGE    = krates/toolbox:2.6.5-3

# Adding PHONY to a target will prevent make from confusing the phony target with a file name.
# In this case, if `test` folder exists, `make test` will still be run.
.PHONY: test publish trace

test: wipe mongodb
	@docker run -ti --rm --link mongodb:localhost --workdir $(TARGET_PATH) -v "$(VOLUME_PATH)" $(RUBY_IMAGE) \
		-c "bundle install && bundle exec rspec spec/"

publish:
	@docker run -ti --rm -e "RUBYGEMS_KEY=$(RUBYGEMS_KEY)" --workdir $(TARGET_PATH) -v "$(VOLUME_PATH)" $(RUBY_IMAGE) \
		-c "./build/deploy_gem.sh"

trace: wipe mongodb
	@docker run -ti --rm --link mongodb:localhost --workdir $(TARGET_PATH) -v "$(VOLUME_PATH)" $(RUBY_IMAGE) \
		-c "bundle install && bash"

mongodb:
	@docker run --rm -d --name mongodb mongo:3.6 mongod --smallfiles

wipe:
	@docker ps -aq | xargs -r docker rm -f