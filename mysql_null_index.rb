require 'benchmark/ips'
require 'sequel'

#`mysql -e "DROP DATABASE index_benchmark; CREATE DATABASE index_benchmark;"`

DB = Sequel.mysql 'index_benchmark'

TIMESTAMP_TABLES = %w[
  timestamp_no_index
  timestamp_index_no_null
  timestamp_index_null
]

BIGINT_TABLES = %w[
  bigint_no_index
  bigint_index_no_null
  bigint_index_null
]

TABLES = TIMESTAMP_TABLES + BIGINT_TABLES

## GENERATE DATA
#
#
# DB.run <<-SQL
# CREATE TABLE `timestamp_no_index` (
#   `id`         int(11)      NOT NULL  AUTO_INCREMENT,
#   `name`       varchar(255) NOT NULL,
#   `user_id`    int(11)      NOT NULL,
#   `deleted_at` timestamp    NULL,
#   PRIMARY KEY (`id`)
# ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
#
# SQL
#
# DB.run <<-SQL
# CREATE TABLE `timestamp_index_no_null` (
#   `id`         int(11)      NOT NULL  AUTO_INCREMENT,
#   `name`       varchar(255) NOT NULL,
#   `user_id`    int(11)      NOT NULL,
#   `deleted_at` timestamp    NOT NULL DEFAULT '0000-00-00 00:00:00',
#   PRIMARY KEY (`id`),
#   KEY `timestamp_index_no_null_user_id_deleted_at_index` (`user_id`, `deleted_at`)
# ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
# SQL
#
# DB.run <<-SQL
# CREATE TABLE `timestamp_index_null` (
#   `id`         int(11)      NOT NULL  AUTO_INCREMENT,
#   `name`       varchar(255) NOT NULL,
#   `user_id`    int(11)      NOT NULL,
#   `deleted_at` timestamp    NULL,
#   PRIMARY KEY (`id`),
#   KEY `timestamp_index_null_user_id_deleted_at_index` (`user_id`, `deleted_at`)
# ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
# SQL
#
# DB.run <<-SQL
# CREATE TABLE `bigint_no_index` (
#   `id`         int(11)      NOT NULL  AUTO_INCREMENT,
#   `name`       varchar(255) NOT NULL,
#   `user_id`    int(11)      NOT NULL,
#   `deleted_at` bigint(20)   NULL,
#   PRIMARY KEY (`id`)
# ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
# SQL
#
# DB.run <<-SQL
# CREATE TABLE `bigint_index_no_null` (
#   `id`         int(11)      NOT NULL  AUTO_INCREMENT,
#   `name`       varchar(255) NOT NULL,
#   `user_id`    int(11)      NOT NULL,
#   `deleted_at` bigint(20)   NOT NULL  DEFAULT '0',
#   PRIMARY KEY (`id`),
#   KEY `bigint_index_no_null_user_id_deleted_at_index` (`user_id`,`deleted_at`)
# ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
# SQL
#
# DB.run <<-SQL
# CREATE TABLE `bigint_index_null` (
#   `id`         int(11)      NOT NULL  AUTO_INCREMENT,
#   `name`       varchar(255) NOT NULL,
#   `user_id`    int(11)      NOT NULL,
#   `deleted_at` bigint(20)   NULL,
#   PRIMARY KEY (`id`),
#   KEY `bigint_index_null_user_id_deleted_at_index` (`user_id`,`deleted_at`)
# ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
# SQL
#
#
# now_str = Time.now.strftime("%Y-%m-%d %H:%M:%S")
# now_int = (Time.now.to_f*1000).to_i
#
# rows =
#   # Across 1000 users
#   1000.times.collect do |uid|
#     # each with 100 tokens
#     100.times.collect do |i|
#       # 90% of which are "deleted"
#       ["Test #{i}", uid, i >= 10 ? now_str.inspect : "NULL"]
#     end
#   end.flatten(1)
#
# TIMESTAMP_TABLES.each do |table|
#   p table
#   DB[table.intern].import([:name, :user_id, :deleted_at], rows, commit_every: 100)
# end
#
# rows =
#   # Across 1000 users
#   1000.times.collect do |uid|
#     # each with 100 tokens
#     100.times.collect do |i|
#       # 90% of which are "deleted"
#       ["Test #{i}", uid, i >= 10 ? now_int : "NULL"]
#     end
#   end.flatten(1)
#
# BIGINT_TABLES.each do |table|
#   p table
#   DB[table.intern].import([:name, :user_id, :deleted_at], rows, commit_every: 100)
# end

Benchmark.ips do |x|
  x.report("timestamp_no_index")      { DB[:timestamp_no_index].where(user_id:      1, deleted_at: nil).all }
  x.report("timestamp_index_no_null") { DB[:timestamp_index_no_null].where(user_id: 1, deleted_at: Time.at(0)).all   }
  x.report("timestamp_index_null")    { DB[:timestamp_index_null].where(user_id:    1, deleted_at: nil).all }

  x.report("bigint_no_index")      { DB[:bigint_no_index].where(user_id:      1, deleted_at: nil).all }
  x.report("bigint_index_no_null") { DB[:bigint_index_no_null].where(user_id: 1, deleted_at: 0).all   }
  x.report("bigint_index_null")    { DB[:bigint_index_null].where(user_id:    1, deleted_at: nil).all }
end
