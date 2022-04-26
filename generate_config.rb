require 'yaml'

current_branch = `git rev-parse --abbrev-ref HEAD`

def checkout(revision)
  `git checkout #{revision}`
end

head = ENV['CIRCLE_SHA1'] || current_branch
base_revision = 'base-js'
# checkout(base_revision)  # Checkout base revision to make sure it is available for comparison
checkout(head) # return to head commit

base = `git merge-base #{base_revision} #{head}`.force_encoding('utf-8').strip

if head == base
  begin
    # If building on the same branch as BASE_REVISION, we will get the
    # current commit as merge base. In that case try to go back to the
    # first parent, i.e. the last state of this branch before the merge, and use that as the base.
    base = `git rev-parse HEAD~1`.force_encoding('utf-8').strip
  rescue
    # This can fail if this is the first commit of the repo, so that
    # HEAD~1 actually doesn't resolve. In this case we can compare
    # against this magic SHA below, which is the empty tree. The diff
    # to that is just the first commit as patch.
    base = '4b825dc642cb6eb9a060e54bf8d69288fbee4904'
  end
end

puts "Comparing #{base}...#{head}"

changes = `git diff --name-only #{base} #{head}`.force_encoding('utf-8').split("\n")


jobs << <<-YAML
      - test_gem_rspec:
          name: #{test_gem_job}
          <<: *default_context
          gem_name: #{gem_name}
          gem_type: #{gem_type}
          executor_name: #{params[:executor] || 'null'}
          nodejs_utils_version: #{params[:nodejs_utils_version] || 'null'}
      - test_gem_sorbet:
          name: #{test_gem_sorbet_job}
          <<: *default_context
          gem_name: #{gem_name}
          gem_type: #{gem_type}
YAML

puts "=============> changes: #{changes.inspect}"


