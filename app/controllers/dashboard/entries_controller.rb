require 'csv'

module Dashboard
  class EntriesController < Dashboard::BaseController
    before_filter :require_current_challenge, only: :index

    def index
      @challenges = organization_challenges
      @current_challenge = current_challenge
      @entries = current_challenge_entries

      respond_to do |format|
        format.html
        format.csv { send_data *dashboard_csv_for(Entry, @entries) }
      end
    end

    def show
      @entry = entry
    end

    def publish
      entry.publish!
      entry.save
      redirect_to dashboard_entries_path(challenge_id: entry.challenge_id)
    end

    def accept
      entry.accept!
      entry.save
      redirect_to dashboard_entries_path(challenge_id: entry.challenge_id), notice: t('flash.entries.accepted_successfully')
    end

    private

    def current_challenge_entries
      current_challenge.entries.order('created_at DESC').includes(:challenge, member: :user)
    end

    def entry
      @_entry ||= Entry.find(params[:id])
    end
  end
end
