require 'spec_helper'

describe RSpec::Given::Fuzzy::FuzzyNumber do
  use_natural_assertions
  include RSpec::Given::Fuzzy


  describe "fixed deltas" do
    context "when created with non-hash delta" do
      Given(:delta) { 0.0001 }
      Given(:number) { about(10, delta) }

      Then { 10 == number }
      Then { number == 10 }

      Then { (10 + 0.0001) == number }
      Then { (10 - 0.0001) == number }

      Then { (10 + 0.000100001) != number }
      Then { (10 - 0.000100001) != number }
    end

    context "when created with explicit delta" do
      Given(:exact_number) { 10 }
      Given(:number) { about(exact_number, delta: 0.001) }

      Then { exact_number == number }

      Then { (exact_number + 0.001) == number }
      Then { (exact_number - 0.001) == number }

      Then { (exact_number + 0.001001) != number }
      Then { (exact_number - 0.001001) != number }
    end
  end

  describe "percentage deltas" do
    Given(:exact_number) { 1 }
    Given(:number) { about(exact_number, percent: 25) }

    Then { exact_number == number }

    Then { (exact_number + 0.25) == number }
    Then { (exact_number - 0.25) == number }

    Then { (exact_number + 0.25001) != number }
    Then { (exact_number - 0.25001) != number }
  end

  describe "small epsilon deltas" do
    Given(:neps) { 10 }
    Given(:hi_in_range) { 1 + neps*Float::EPSILON }
    Given(:lo_in_range) { 1 - neps*Float::EPSILON }
    Given(:hi_out_of_range) { 1 + (neps+1)*Float::EPSILON }
    Given(:lo_out_of_range) { 1 - (neps+1)*Float::EPSILON }

    Invariant { exact_number*hi_in_range == number }
    Invariant { exact_number*lo_in_range == number }

    Invariant { exact_number*hi_out_of_range != number }
    Invariant { exact_number*lo_out_of_range != number }

    context "when created with default delta" do
      Given(:number) { about(exact_number) }

      context "when 1" do
        Given(:exact_number) { 1 }
        Then { exact_number == number }
      end

      context "when rather large" do
        Given(:exact_number) { 1_000_000 }
        Then { exact_number == number }
      end

      context "when rather small" do
        Given(:exact_number) { 0.000_001 }
        Then { exact_number == number }
      end
    end

    context "when created with small epsilon" do
      Given(:neps) { 100 }
      Given(:exact_number) { 10 }
      Given(:number) { about(exact_number, epsilon: neps) }
      Then { exact_number == number }
    end
  end

  describe "#to_s" do
    Given(:number) { about(10, delta: 0.0001) }
    Then { number.to_s == "<Approximately 10 +/- 0.0001>" }
  end

  describe "invalid options" do
    context "with an illegal option" do
      When(:result) { about(10, junk: 1) }
      Then { result == have_failed(ArgumentError, /invalid.*junk/i) }
    end

    context "with too many options" do
      When(:result) { about(10, epsilon: 1, delta: 10) }
      Then { result == have_failed(ArgumentError, /too many/i) }
      And  { result == have_failed(ArgumentError, /epsilon/i) }
      And  { result == have_failed(ArgumentError, /delta/i) }
    end

    context "with no options" do
      When(:result) { about(10, {}) }
      Then { result == have_failed(ArgumentError, /no options/i) }
    end
  end
end
