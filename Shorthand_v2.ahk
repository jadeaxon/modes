#Requires AutoHotkey v2.0

#SingleInstance Force

TraySetIcon(A_ScriptDir "\Icons\Shorthand_v2.ico")

#Hotstring C

::+::more
::-::less
::!::not
::b::be
::c::can
::d::do
::f::for
::i::is
::l::like
::m::me
::n::and
::o::of
::r::are
::s::some
::t::the
::u::you
::w::with
::AA::A
::A::action
::B::able
::G::thing
::aa::and
::m+::many 
::tt::that
::ts::this
::tn::than
::tm::them
::ct::can't
::c!::cannot
::hv::have
::bn::been
::hvt::haven't 
::hv!::have not
::un-::unless
::fr::from
::af::after
::b4::before
::w2::want to
::b+::better
::un::under
::ov::over
::tr::there
::t4::therefore
::4u::for you
::4m::for me
::4v::forever
::4tn::fortune
::4tn8::fortunate
::4tn8y::fortunately
::u4tn8y::unfontunately
::bc::because
::bco::because of
::aG::anything
::eG::everything
::sG::something
::uv::you've
::sth::something
::sthe::something else
::nG::nothing
::nGe::nothing else
::s1::someone
::a1::anyone
::n1::no one
::bB2::be able to
::reA::reaction
::fA::faction
::frA::fraction
::trA::traction
::inA::inaction
::reA::reaction
::retrA::retraction
::*tude::multitude
::*ply::multiply
::*ple::multiple
::noT::notion
::naT::nation
::naTl::national
::naTlZ::nationalize
::sud::should
::sudh::should have
::sud!h::should not have
::sudt::shouldn't
::sudth::shouldn't
::sud!::should not
::sudb::should be
::sudbB2::should be able to
::sud!bB2::should not be able to
::cud::could
::cudh::could have
::cudt::could not
::wud::would
::wudt::wouldn't
::wud!::would not
::wudh::would have
::wudbB2::would be able to
::wudl2::would like to
::xT::transition
::i18n::internationalization
::varB::variable
::edB::edible
::care-::careless
::care+::careful
::thought-::thoughtless
::thought+::thoughtful
::gr8+::grateful
::aD::attitude
::alD::altitude
::apD::aptitude
::ampD::amplitude
::graD::gratitude
::.-::pointless
::qt::what
::qte::whatever
::qr::where
::qre::wherever
::qn::when
::qne::whenever
::qo::who
::qoe::whoever
::qh::which
::qw::how
::qwe::however
::qwm::how many
::?::what
::?o::who
::?n::when
::?r::where
::?e::whatever
::?oe::whoever
::?ne::whenever
::?re::wherever
::Inet::internet
::INl::international
::IA::interaction
::IAG::interacting
::creaT::creation
::creatG::creating
::nH::night
::lH::light
::lHG::lighting
::lHnG::lightning
::blH::blight
::hH::height
::rH::right
::flH::flight
::flH-::flightless

RemoveToolTip() => ToolTip()

; Terminate this keystroke handler. End this mode.
LControl & Escape:: {
	ToolTip("Shorthand mode OFF")
	Suspend(true)
	SetTimer(RemoveToolTip, -2000)
	Sleep(2000)
	ExitApp
}

