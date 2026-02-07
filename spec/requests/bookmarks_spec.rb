require "rails_helper"

RSpec.describe "Bookmarks", type: :request do
  let(:user) { create(:user) }

  describe "POST /bookmarks" do
    context "when authenticated" do
      before { sign_in(user) }

      it "creates a bookmark with valid attributes" do
        expect {
          post bookmarks_path, params: {
            bookmark: {
              title: "Ruby on Rails",
              url: "https://rubyonrails.org",
              description: "Official Rails website",
              is_public: true
            }
          }
        }.to change(Bookmark, :count).by(1)

        expect(response).to redirect_to(bookmarks_path)

        bookmark = Bookmark.last
        expect(bookmark.title).to eq("Ruby on Rails")
        expect(bookmark.url).to eq("https://rubyonrails.org")
        expect(bookmark.description).to eq("Official Rails website")
        expect(bookmark.is_public).to be true
      end

      it "creates a bookmark and assigns it to the current user" do
        post bookmarks_path, params: {
          bookmark: {
            title: "GitHub",
            url: "https://github.com",
            description: "Code hosting"
          }
        }

        bookmark = Bookmark.last
        expect(bookmark.user).to eq(user)
      end

      it "generates a short code for the bookmark" do
        post bookmarks_path, params: {
          bookmark: {
            title: "Example",
            url: "https://example.com"
          }
        }

        bookmark = Bookmark.last
        expect(bookmark.short_code).to be_present
        expect(bookmark.short_code.length).to eq(6)
      end

      it "creates a bookmark with tags" do
        post bookmarks_path, params: {
          bookmark: {
            title: "Tagged Bookmark",
            url: "https://example.com",
            tag_list: "ruby, rails, programming"
          }
        }

        bookmark = Bookmark.last
        expect(bookmark.tags.pluck(:name)).to contain_exactly("ruby", "rails", "programming")
      end

      it "normalises URLs without a protocol" do
        post bookmarks_path, params: {
          bookmark: {
            title: "No Protocol",
            url: "example.com"
          }
        }

        bookmark = Bookmark.last
        expect(bookmark.url).to eq("https://example.com")
      end

      it "returns unprocessable entity with invalid attributes" do
        post bookmarks_path, params: {
          bookmark: {
            title: "",
            url: ""
          }
        }

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "does not create a bookmark with missing title" do
        expect {
          post bookmarks_path, params: {
            bookmark: {
              url: "https://example.com"
            }
          }
        }.not_to change(Bookmark, :count)
      end

      it "normalises non-http URLs by adding https prefix" do
        post bookmarks_path, params: {
          bookmark: {
            title: "FTP URL",
            url: "ftp://example.com"
          }
        }

        bookmark = Bookmark.last
        expect(bookmark.url).to eq("https://ftp://example.com")
      end
    end

    context "when not authenticated" do
      it "redirects to sign in" do
        post bookmarks_path, params: {
          bookmark: {
            title: "Test",
            url: "https://example.com"
          }
        }

        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "POST /bookmarks (JSON)" do
    context "when authenticated" do
      before { sign_in(user) }

      it "creates a bookmark and returns JSON" do
        post bookmarks_path, params: {
          bookmark: {
            title: "API Created",
            url: "https://api.example.com",
            description: "Created via API"
          }
        }, as: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to include("application/json")
      end

      it "returns errors for invalid bookmark as JSON" do
        post bookmarks_path, params: {
          bookmark: {
            title: "",
            url: ""
          }
        }, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end
    end

    context "when not authenticated" do
      it "returns unauthorized" do
        post bookmarks_path, params: {
          bookmark: {
            title: "Test",
            url: "https://example.com"
          }
        }, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
