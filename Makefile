TERRAFORM:=$(realpath bin)/terraform

S3_BUCKET:=

GLUE_ROLE:=glue_execute
CRAWLER_NAME:=glue-crawler
PATTERN_1_TARGET:={"S3Targets": [{"Path": "s3://$(S3_BUCKET)/glue/pattern_1/", "Exclusions": []}]}
PATTERN_2_TARGET:={"S3Targets": [{"Path": "s3://$(S3_BUCKET)/glue/pattern_2/", "Exclusions": []}]}
PATTERN_1_QUERY:=select * from "default"."name" as name join "group"on name.id = "group".id
PATTERN_2_QUERY:=select * from "default"."name" as name join "group"on name.id = "group".id

all: init create-crawler

init:
	cd _terraform && $(TERRAFORM) init && $(TERRAFORM) apply -var 's3_bucket=$(S3_BUCKET)'
	aws s3 cp data/ s3://$(S3_BUCKET)/glue/ --recursive

pattern_1: TARGET=$(PATTERN_1_TARGET)
pattern_1: update-crawler execute-crawler

pattern_2: TARGET=$(PATTERN_2_TARGET)
pattern_2: update-crawler execute-crawler

create-crawler:
	aws glue create-crawler --name $(CRAWLER_NAME) --role glue_execute\
  --database-name default --targets '$(PATTERN_1_TARGET)'
	aws glue get-crawler --name $(CRAWLER_NAME)
	touch crawler.up

update-crawler: crawler.up
	aws glue update-crawler --name $(CRAWLER_NAME) --role glue_execute\
  --database-name default --targets '$(TARGET)'

execute-crawler: crawler.up
	aws glue start-crawler --name $(CRAWLER_NAME)

delete-crawler: crawler.up
	aws glue delete-crawler --name $(CRAWLER_NAME)
	rm -f crawler.up

run-query:
	aws athena start-query-execution --query-string '$(PATTERN_2_QUERY)' --result-configuration '{"OutputLocation": "s3://$(S3_BUCKET)/output"}'
