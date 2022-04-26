require 'yaml'

current_branch = `git rev-parse --abbrev-ref HEAD`

def checkout(revision)
  `git checkout #{revision}`
end

head = ENV['CIRCLE_SHA1'] || current_branch
base_revision = 'base-js'
checkout(base_revision)  # TODO: comment this line to run at your local
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

puts "=============> changes: #{changes.inspect}"

run_ruby_test = false
run_js_test = false

changes.each do |c|
  if /\.js$/ =~ c
    run_js_test = true
  end

  if /\.rb$/ =~ c
    run_ruby_test = true
  end
end

params = <<~YAML
parameters:
  run_ruby_test:
    type: boolean
    default: #{run_ruby_test}
  run_js_test:
    type: boolean
    default: #{run_js_test}
YAML

template = File.read(File.join(__dir__, 'config-template.yml'))
config = [template, params].join("\n")

File.write(File.join(__dir__, 'config-generated.yml'), config)
