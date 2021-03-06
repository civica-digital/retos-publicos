class DashboardController < Dashboard::BaseController
  layout 'dashboard'

  def show
    @challenges = top_five(organization_challenges)
    @entries = top_five(organization_entries)
  end

  private

  def organization_challenges
    organization.challenges.includes(:collaborators, :entries)
  end

  def organization_entries
    Entry.where(challenge_id: organization.challenge_ids).
      includes(:challenge, member: :user)
  end

  def top_five(relation)
    relation.order('created_at DESC').limit(5)
  end
end
