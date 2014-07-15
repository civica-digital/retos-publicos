require 'csv'

module Dashboard
  class EntriesController < Dashboard::BaseController
    before_filter :require_current_challenge, only: :index

    def index
      @challenges = organization_challenges
      @current_challenge = current_challenge
      @entries = current_challenge_entries
      @current_phase = Phases.current(current_challenge)

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
      EntriesMailer.entry_accepted(entry).deliver
      redirect_to dashboard_entries_path(challenge_id: entry.challenge_id), notice: t('flash.entries.accepted_successfully')
    end

    def winner
      select_entry_as_winner
      redirect_to dashboard_entries_path(challenge_id: entry.challenge_id), notice: t('flash.entries.winner_selected_successfully')
    end

    def remove_winner
      unselect_entry_as_winner
      redirect_to dashboard_entries_path(challenge_id: entry.challenge_id), notice: t('flash.entries.winner_removed_successfully')
    end

    private

    def select_entry_as_winner
      entry.winner = 1
      entry.save
    end

    def unselect_entry_as_winner
      entry.winner = nil
      entry.save
    end

    def current_challenge_entries
      default = current_challenge.entries.order('created_at DESC').includes(:challenge, member: :user)

      if params[:filter] == 'accepted'
        default.accepted
      else
        default
      end
    end

    def entry
      @_entry ||= Entry.find(params[:id])
    end
  end
end
