require File.join(File.dirname(__FILE__), "../../config/environment")

namespace :scraper do
  desc "Raketasks for scrapers."

  task :hub do
    puts "Launching Hub Worker"
    ScraperHubSitesWorker.scrap
  end

  task :group do
    puts "Launching Group Worker "
    ScraperGroupSitesWorker.scrap
  end

  task :premium do
    puts "Launching Premium Worker"
    ScraperPremiumSitesWorker.scrap
  end

<<<<<<< HEAD
  task :independant do
    puts "Launching Independant Worker"
    ScraperIndependantSitesWorker.scrap
=======
  task :small_site do
    puts "Launching Small Shitty Website Scraper"
    puts "...\n\n"
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    ScraperOrpi.new.launch(20)
    ScraperProprietesFigaro.new.launch
    ScraperMorissImmobilier.new.launch
    ScraperFoncia.new.launch
    ScraperKmi.new.launch
    ScraperEfficity.new.launch
    ScraperGreenAcres.new.launch
    ScraperCallImmo.new.launch
    ScraperLesParisiennesImmo.new.launch
    ScraperDeferla.new.launch
    ScraperLaforet.new.launch
    ScraperErnest.new.launch
    ScraperParisMontmartreImmobilier.new.launch
    ScraperLaResidence.new.launch
    ScraperArcales.new.launch
    ScraperEngelVoelkers.new.launch
    ScraperHosman.new.launch
    ScraperStephanePlaza.new.launch
    ScraperIad.new.launch
    ScraperProprioo.new.launch
    ScraperImmobilierSurMesure.new.launch
    ScraperTerrasseCie.new.launch
    ScraperLiberkeys.new.launch
    ScraperLuxResidence.new.launch
    ScraperAssasImmo.new.launch
    ScraperVillageBleu.new.launch
    ScraperJunot.new.launch
    ScraperSotheby.new.launch
    ScraperHomizy.new.launch
    ScraperAristimmo.new.launch
    ScraperDeliquietImmobilier.new.launch
    ScraperConnexionImmobilier.new.launch
    ScraperEraFrance.new.launch
    ScraperLadresse.new.launch
    ScraperVarenne.new.launch
    ScraperEnfantsRouges.new.launch
    ScraperVillaret.new.launch
    ScraperSistelImmo.new.launch
    ScraperCphImmobilier.new.launch
    ScraperEmileGarcin.new.launch
    ScraperAmourImmo.new.launch
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts "\nThe Small Shitty Website Scraper script took #{ending - starting} seconds to run"
>>>>>>> 4a7bbc2582183eb9cf0140f6d5ea1f30efceb1ef
  end
end

namespace :subscriber do
  desc "All the tasks required for Subscribers Actions"

  task :reactivation do
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    Manychat.new.reactivate_inactive_subscribers
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts "The Reactivation script took #{ending - starting} seconds to run"
  end
end

namespace :broadcast do
  desc "This is a task for broadcasting messages to our users."

  task :new_properties_gallery do
    puts "This will broadcast new scraped properties to active subscribers"
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    Broadcaster.new.new_properties_gallery
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts "The new_properties broadcast script took #{ending - starting} seconds to run"
  end

  task :good_morning do
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    Broadcaster.new.good_morning
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts "The Good Morning Broadcaster script took #{ending - starting} seconds to run"
  end
end

namespace :test do
  desc "This runs test"
  task :services do
    RSpec::Core::RakeTask.new(:spec) do |t|
      t.pattern = "spec/services/*/_spec.rb"
    end
    Rake::Task["spec"].execute
  end
end
