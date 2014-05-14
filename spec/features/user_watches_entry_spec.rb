require 'spec_helper'

feature 'User watches entry' do
  scenario 'in the challenge page' do
    member = new_member
    organization = new_organization
    challenge = create :challenge, title: 'Reto 1', organization: organization
    collaboration = create :collaboration, challenge: challenge, member: member

    create :entry, :public,
      member: member,
      challenge: challenge,
      name: 'App de prueba',
      description: 'App description',
      github_url: 'https://github.com/CodeandoMexico/aquila',
      live_demo_url: 'http://codeandomexico.org'

    visit challenge_path(challenge)
    click_link '1 App'
    page_should_have_entry(
      name: 'App de prueba',
      description: 'App description',
      github_link: ['Repo', 'https://github.com/CodeandoMexico/aquila'],
      demo_link: ['Demo', 'http://codeandomexico.org']
    )
  end

  def page_should_have_entry(entry)
    within '#entries_tab_pane' do
      page.should have_content entry.fetch(:name)
      page.should have_content entry.fetch(:description)
      page.should have_link *entry.fetch(:github_link)
      page.should have_link *entry.fetch(:demo_link)
    end
  end
end
