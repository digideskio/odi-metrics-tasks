require 'spec_helper'

describe CompanyDashboard do

  it "should store right values in metrics API" do
    WebMock.allow_net_connect!
    Timecop.freeze(Date.new(2014, 2, 4))
    time = DateTime.now
    {
      "current-year-reach"                   => 775655,
      "cumulative-reach"                     => 1079051,
      "current-year-active-reach"            => 432423,
      "current-year-passive-reach"           => 343232,
      "current-year-bookings"                => 0,
      "cumulative-bookings"                  => 2191064,
      "current-year-value-unlocked"          => 775655,
      "cumulative-value-unlocked"            => 17699962,
      "current-year-commercial-bookings"     => '{"actual": 78.0,"target": 874.48}',
      "current-year-non-commercial-bookings" => '{"actual": 156.0,"target": 45.2}',
      "current-year-kpi-performance"         => 1.0,
      "current-year-grant-funding"           => '{"actual": 3040.00,"target": 3354.6176046176}',
      "current-year-income-by-type"          => '{"research": 900.00,"training": 289.00,"projects": 900.00,"network": 912.00}',
      "current-year-income-by-sector"        => '{"research":{"commercial":{"actual":890.0,"target":1500.0},"non_commercial":{"actual":423.0,"target":750.0}},"training":{"commercial":{"actual":87.0,"target":128.12},"non_commercial":{"actual":121.0,"target":180.78}},"projects":{"commercial":{"actual":123.0,"target":450.0},"non_commercial":{"actual":212.0,"target":500.0}},"network":{"commercial":{"actual":78.0,"target":874.48},"non_commercial":{"actual":156.0,"target":45.2}}}',
      "current-year-headcount"               => '{"actual": 22.0,"target": 26.0}',
      "current-year-burn"                    => '{"actual": 0.0,"target": 340.476666666667}',
      "current-year-people-trained"          => '{"commercial": {"actual": 0,"target": 190}, "non_commercial": {"actual": 0,"target": 206}}',
      "current-year-network-size"            => '{"partners":{"actual":0,"target":10},"sponsors":{"actual":0,"target":5},"supporters":{"actual":0,"target":34},"startups":{"actual":0,"target":6},"nodes":{"actual":0,"target":20}}',
      "current-year-ebitda"                  => '{"actual":275.5, "target":-82.7897922077922}',
      "current-year-total-costs"             => '{"actual":0.0,"target":365.60200000000026,"breakdown":{"variable":{"research":{"actual":0.0,"target":0.0},"training":{"actual":0.0,"target":8.92},"projects":{"actual":0.0,"target":10.8166666666667},"network":{"actual":0.0,"target":5.38866666666667}},"fixed":{"staff":{"actual":0.0,"target":147.0},"associates":{"actual":0.0,"target":57.0},"office_and_operational":{"actual":0.0,"target":41.1666666666667},"delivery":{"actual":0.0,"target":43.9933333333333},"communications":{"actual":0.0,"target":26.25},"professional_fees":{"actual":0.0,"target":16.6666666666667},"software":{"actual":0.0,"target":8.4}}}}',
    }.each_pair do |metric, value|
      metrics_api_should_receive metric, time, value
    end

    CompanyDashboard.perform
    Timecop.return
    WebMock.disable_net_connect!
  end

  it "should show the correct reach", :vcr do
    CompanyDashboard.reach.should == 1079051
  end

  it "should show the correct reach for 2013", :vcr do
    CompanyDashboard.reach(2013).should == 303396
  end

  it "should show the correct reach for 2014", :vcr do
    CompanyDashboard.reach(2014).should == 775655
  end

  it "should show the correct active reach", :vcr do
    CompanyDashboard.reach(2014, "Active").should == 432423
  end

  it "should show the correct passive reach", :vcr do
    CompanyDashboard.reach(2014, "Passive").should == 343232
  end

  it "should show the correct bookings value", :vcr do
    CompanyDashboard.bookings(2013).should == 2191064
    CompanyDashboard.bookings(2014).should == 0
    CompanyDashboard.bookings.should == 2191064
  end

  it "should show the correct unlocked value", :vcr do
    CompanyDashboard.value(2013).should == 16924307
    CompanyDashboard.value(2014).should == 775655
    CompanyDashboard.value.should == 17699962
  end

  it "should show the correct kpi percentage", :vcr do
    CompanyDashboard.kpis(2013).should == 100.0
    CompanyDashboard.kpis(2014).should == 1.0
  end

  it "should show the correct network size", :vcr do
    CompanyDashboard.network.should == {
        :total     => 0,
        :breakdown => {
            :members    => 0,
            :nodes      => 0,
            :startups   => 0,
            :affiliates => 0
        }
    }
  end

  it "should show total commercial bookings", :vcr do
    CompanyDashboard.bookings_by_type("Commercial", 2014).should == {
        actual: 78.0,
        target: 874.48
    }
  end

  it "should show total non-commercial bookings", :vcr do
    CompanyDashboard.bookings_by_type("Non-commercial", 2014).should == {
        actual: 156.0,
        target: 45.2
    }
  end

  it "should show total grant funding", :vcr do
    CompanyDashboard.grant_funding(2014).should == {
        actual: 3040.00,
        target: 3354.6176046176
    }
  end

  it "should show total income", :vcr do
    CompanyDashboard.total_income(2014).should == 6041
  end

  it "should show income by type", :vcr do
    CompanyDashboard.income_by_type(2014).should == {
        research: 900.00,
        training: 289.00,
        projects: 900.00,
        network:  912.00
    }
  end

  it "should show the correct income by sector", :vcr do
    CompanyDashboard.income_by_sector(2014).should == {
        research: {
            commercial:     {
                actual: 890.00,
                target: 1500.00
            },
            non_commercial: {
                actual: 423.00,
                target: 750.00
            }
        },
        training: {
            commercial:     {
                actual: 87.00,
                target: 128.12
            },
            non_commercial: {
                actual: 121.00,
                target: 180.78
            }
        },
        projects: {
            commercial:     {
                actual: 123.00,
                target: 450.00
            },
            non_commercial: {
                actual: 212.00,
                target: 500.00
            }
        },
        network:  {
            commercial:     {
                actual: 78.00,
                target: 874.48
            },
            non_commercial: {
                actual: 156.00,
                target: 45.2
            }
        }
    }
  end

  it "should show headcount", :vcr do
    Timecop.freeze(Date.new(2014, 2, 4))
    CompanyDashboard.headcount(2014, 2).should == {
        actual: 22.0,
        target: 26.0
    }
    Timecop.return
  end

  it "should show burn", :vcr do
    Timecop.freeze(Date.new(2014, 1, 4))
    CompanyDashboard.burn_rate(2014, 1).should == {
        actual: 320.0,
        target: 314.766666666667
    }
    Timecop.return
  end

  it "should show number of people trained", :vcr do
    CompanyDashboard.people_trained(2014).should == {
        commercial:     {
            actual: 0,
            target: 190
        },
        non_commercial: {
            actual: 0,
            target: 206
        }
    }
  end

  it "should show correct network size", :vcr do
    CompanyDashboard.network_size(2014).should == {
        partners:   {
            actual: 0,
            target: 10
        },
        sponsors:   {
            actual: 0,
            target: 5
        },
        supporters: {
            actual: 0,
            target: 34
        },
        startups:   {
            actual: 0,
            target: 6
        },
        nodes:      {
            actual: 0,
            target: 20
        }
    }
  end

  it "should load EBITDA information", :vcr do
    Timecop.freeze(Date.new(2014, 1, 4))
    CompanyDashboard.ebitda(2014, 1).should == {
        actual: -44.5,
        target: -69.9797922077923
    }
    Timecop.return
  end

  it "should load total cost information", :vcr do
    Timecop.freeze(Date.new(2014, 1, 4))
    CompanyDashboard.total_costs(2014, 1).should == {
        actual:    320.0,
        target:    334.238666666667,
        breakdown: {
            variable: {
                research: {
                    actual: 0.0,
                    target: 0.0
                },
                training: {
                    actual: 0.0,
                    target: 3.856
                },
                projects: {
                    actual: 0.0,
                    target: 10.8166666666667
                },
                network:  {
                    actual: 0.0,
                    target: 4.79933333333333
                }
            },
            fixed:    {
                staff:                  {
                    actual: 5432.0,
                    target: 130.0
                },
                associates:             {
                    actual: 54.0,
                    target: 55.0
                },
                office_and_operational: {
                    actual: 4321.0,
                    target: 41.1666666666667
                },
                delivery:               {
                    actual: 54.0,
                    target: 37.8833333333333
                },
                communications:         {
                    actual: 6543.0,
                    target: 26.25
                },
                professional_fees:      {
                    actual: 765.0,
                    target: 16.6666666666667
                },
                software:               {
                    actual: 4324.0,
                    target: 7.8
                }
            }
        }
    }
    Timecop.return
  end

  after :each do
    CompanyDashboard.clear_cache!
  end

end