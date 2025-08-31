# frozen_string_literal: true

require "spec_helper"

describe Products::AffiliatedPolicy do
  subject { described_class }

  # Users
  let(:accountant_for_seller) { create(:user) }
  let(:admin_for_seller) { create(:user) }
  let(:marketing_for_seller) { create(:user) }
  let(:support_for_seller) { create(:user) }
  let(:seller) { create(:named_seller) }

  # Affiliates
  let(:direct_affiliate) { create(:direct_affiliate, affiliate_user: admin_for_seller, seller:) }

  before do
    create(:team_membership, user: accountant_for_seller, seller:, role: TeamMembership::ROLE_ACCOUNTANT)
    create(:team_membership, user: admin_for_seller, seller:, role: TeamMembership::ROLE_ADMIN)
    create(:team_membership, user: marketing_for_seller, seller:, role: TeamMembership::ROLE_MARKETING)
    create(:team_membership, user: support_for_seller, seller:, role: TeamMembership::ROLE_SUPPORT)
  end

  permissions :index? do
    it "grants access to owner" do
      seller_context = SellerContext.new(user: seller, seller:)
      expect(subject).to permit(seller_context, :affiliated)
    end

    it "grants access to accountant" do
      seller_context = SellerContext.new(user: accountant_for_seller, seller:)
      expect(subject).to permit(seller_context, :affiliated)
    end

    it "grants access to admin" do
      seller_context = SellerContext.new(user: admin_for_seller, seller:)
      expect(subject).to permit(seller_context, :affiliated)
    end

    it "grants access to marketing" do
      seller_context = SellerContext.new(user: marketing_for_seller, seller:)
      expect(subject).to permit(seller_context, :affiliated)
    end

    it "grants access to support" do
      seller_context = SellerContext.new(user: support_for_seller, seller:)
      expect(subject).to permit(seller_context, :affiliated)
    end
  end

  permissions :destroy? do
    it "grants access when all conditions are met" do
      seller_context = SellerContext.new(user: admin_for_seller, seller:)
      expect(subject).to permit(seller_context, direct_affiliate)
    end

    it "denies access when user is not the affiliate user" do
      different_affiliate = create(:direct_affiliate, affiliate_user: accountant_for_seller, seller:)
      seller_context = SellerContext.new(user: admin_for_seller, seller:)
      expect(subject).not_to permit(seller_context, different_affiliate)
    end

    it "denies access when affiliate is not a direct affiliate" do
      global_affiliate = admin_for_seller.global_affiliate
      seller_context = SellerContext.new(user: admin_for_seller, seller:)
      expect(subject).not_to permit(seller_context, global_affiliate)
    end

    it "denies access when record is nil" do
      seller_context = SellerContext.new(user: admin_for_seller, seller:)
      expect(subject).not_to permit(seller_context, nil)
    end

    it "denies access when affiliate is soft-deleted" do
      soft_deleted_affiliate = create(:direct_affiliate, affiliate_user: admin_for_seller, seller:, deleted_at: 1.hour.ago)
      seller_context = SellerContext.new(user: admin_for_seller, seller:)
      expect(subject).not_to permit(seller_context, soft_deleted_affiliate)
    end
  end
end
