require 'cucumber/formatter/html'

module Cucumber
  module Formatter
    class HtmlLink < Html
      def build_step(keyword, step_match, status)
        # step_name = step_match.format_args(lambda{|param| %{<span class="param">#{param}</span>}})
        step_name = step_match.format_args(lambda{|param| %{<span class="param"><a href="#{param}" target="_blank">#{param}</a></span>}})

        @builder.div(:class => 'step_name') do |div|
          @builder.span(keyword, :class => 'keyword')
          @builder.span(:class => 'step val') do |name|
            # name << h(step_name).gsub(/&lt;span class=&quot;(.*?)&quot;&gt;/, '<span class="\1">').gsub(/&lt;\/span&gt;/, '</span>')
            if step_name.include? '.json'
              name << h(step_name).gsub(/&lt;span class=&quot;(.*?)&quot;&gt;/, '<span class="\1">').gsub(/&lt;\/span&gt;/, '</span>').gsub(/&lt;a href=&quot;(.*?)&quot; target=&quot;_blank&quot;&gt;/, '<a href="\1" target="_blank">').gsub(/&lt;\/a&gt;/, '</a>')
            else
              name << h(step_name).gsub(/&lt;span class=&quot;(.*?)&quot;&gt;/, '<span class="\1">').gsub(/&lt;\/span&gt;/, '</span>').gsub(/&lt;a href=&quot;(.*?)&quot; target=&quot;_blank&quot;&gt;/, '').gsub(/&lt;\/a&gt;/, '')
            end
          end
        end

        step_file = step_match.file_colon_line
        step_file.gsub(/^([^:]*\.rb):(\d*)/) do
          if ENV['TM_PROJECT_DIRECTORY']
            step_file = "<a href=\"txmt://open?url=file://#{File.expand_path($1)}&line=#{$2}\">#{$1}:#{$2}</a> "
          end
        end

        @builder.div(:class => 'step_file') do |div|
          @builder.span do
            @builder << step_file
          end
        end
      end

      def print_messages
        return if @delayed_messages.empty?

        #@builder.ol do
          @delayed_messages.each do |ann|
            @builder.li(:class => 'step message') do
	            if ann.include? '.json'
	            	@builder << %{<a href="#{ann}" target="_blank">#{ann}</a>}
	            else
	            	@builder << ann
	            end
            end
          end
        #end
        empty_messages
      end

      def inline_js_content
        <<-EOF
  SCENARIOS = "h3[id^='scenario_'],h3[id^=background_]";
  $(document).ready(function() {
    $(SCENARIOS).css('cursor', 'pointer');
    $(SCENARIOS).click(function() {
      $(this).siblings().toggle(250);
    });
    $("#collapser").css('cursor', 'pointer');
    $("#collapser").click(function() {
      $(SCENARIOS).siblings().hide();
    });
    $("#expander").css('cursor', 'pointer');
    $("#expander").click(function() {
      $(SCENARIOS).siblings().show();
    });

  // 下面是新加的
  $("td.message").each(function(index,element){
    if ($(element).text().indexOf(".json") > 0) {
      text = $(element).text()
      href = "<a>" + text + "</a>"
      $(element).html(href)
      $(element).children("a").attr({
        "href" : text,
        "target" : "_blank"
      });
    }
  });


  // 上面是新加的

  })
  function moveProgressBar(percentDone) {
    $("cucumber-header").css('width', percentDone +"%");
  }
  function makeRed(element_id) {
    $('#'+element_id).css('background', '#C40D0D');
    $('#'+element_id).css('color', '#FFFFFF');
  }
  function makeYellow(element_id) {
    $('#'+element_id).css('background', '#FAF834');
    $('#'+element_id).css('color', '#000000');
  }

        EOF
      end

    end
  end
end