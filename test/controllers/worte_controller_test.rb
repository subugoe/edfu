require 'test_helper'

class WorteControllerTest < ActionController::TestCase
  setup do
    @wort = worte(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:worte)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create wort" do
    assert_difference('Wort.count') do
      post :create, wort: { anmerkung: @wort.anmerkung, belegstellenEdfu: @wort.belegstellenEdfu, belegstellenWb: @wort.belegstellenWb, hieroglyph: @wort.hieroglyph, transliteration: @wort.transliteration, transliteration_nosuffix: @wort.transliteration_nosuffix, uebersetzung: @wort.uebersetzung, uid: @wort.uid, weiteres: @wort.weiteres }
    end

    assert_redirected_to wort_path(assigns(:wort))
  end

  test "should show wort" do
    get :show, id: @wort
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @wort
    assert_response :success
  end

  test "should update wort" do
    patch :update, id: @wort, wort: { anmerkung: @wort.anmerkung, belegstellenEdfu: @wort.belegstellenEdfu, belegstellenWb: @wort.belegstellenWb, hieroglyph: @wort.hieroglyph, transliteration: @wort.transliteration, transliteration_nosuffix: @wort.transliteration_nosuffix, uebersetzung: @wort.uebersetzung, uid: @wort.uid, weiteres: @wort.weiteres }
    assert_redirected_to wort_path(assigns(:wort))
  end

  test "should destroy wort" do
    assert_difference('Wort.count', -1) do
      delete :destroy, id: @wort
    end

    assert_redirected_to worte_path
  end
end
