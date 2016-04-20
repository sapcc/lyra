require 'rails_helper'
include Pagination

RSpec.describe "PaginationInfo" do

  it "should set the defaults" do
    pag = PaginationInfo.new()
    expect(pag.page).to be == 1
    expect(pag.total_pages).to be == 1
    expect(pag.per_page).to be == 10
    expect(pag.total_elememts).to be == 0
  end

  it "should correct wrong initial values" do
    pag = PaginationInfo.new(100, -2, 200)
    expect(pag.page).to be == 1
    expect(pag.per_page).to be == 25
    expect(pag.total_pages).to be == 4
    expect(pag.total_elememts).to be == 100
  end

  it "should set the page" do
    pag = PaginationInfo.new(10, 10, 2)
    expect(pag.page).to be == 5
    expect(pag.per_page).to be == 2
    expect(pag.total_pages).to be == 5
    expect(pag.total_elememts).to be == 10
  end

  it "should calculate total of pages" do
    pag = PaginationInfo.new(150, 1, 25)
    expect(pag.total_pages).to be == 6
    pag = PaginationInfo.new(50, 1, 25)
    expect(pag.total_pages).to be == 2
    pag = PaginationInfo.new(0, 1, 25)
    expect(pag.total_pages).to be == 1
  end

end