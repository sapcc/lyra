module Pagination

  class PaginationInfo

    LIMIT = 25
    DEFAULT = 10

    attr_reader :page, :per_page, :total_pages, :total_elememts

    def initialize(total_elements=0, page=1, per_page=DEFAULT)
      @total_elememts = total_elements.to_i

      # per page
      per_page.nil? ? per_page = DEFAULT : per_page = per_page.to_i
      if per_page > LIMIT
        @per_page = LIMIT
      elsif per_page < 1
        @per_page = 1
      else
        @per_page = per_page
      end

      # total_pages
      @total_pages = calc_total_pages(@total_elememts)

      # page
      page.nil? ? page = 1 : page = page.to_i
      if page > @total_pages
        @page = @total_pages
      elsif page < 1
        @page = 1
      else
        @page = page
      end

    end

    def headers(response)
      response.headers['Pagination-Elements'] = @total_elememts
      response.headers['Pagination-Pages'] = @total_pages
      response.headers['Pagination-Page'] = @page
      response.headers['Pagination-Per-Page'] = @per_page
    end

    private

    def calc_total_pages(total_entries=0)
      pages = total_entries / @per_page
      if total_entries%@per_page > 0
        pages += 1
      end
      pages = 1 if pages == 0
      pages
    end

  end

end