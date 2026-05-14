#Requires AutoHotkey v2.0

#SingleInstance Force

TraySetIcon(A_ScriptDir "\Icons\Shorthand_v2.ico")

/*
A - action
B - able, ible
C - cise, ence, erence
G - ing, thing
H - ight
M - ment
mT - mission
N - ness
S - ous
T - tion, sion
V - ive
VN - iveness
X - trans, cross
Y - ity, ary
Z - ization

t= - test
_ - under
; - semi
, - com, comm, con
/ - lean or slash
\ - back
- - less
-N - lessness
+ - ful
+N - fulness
* - multi
8 - ate

*/

; These should only affect the hotstrings in this file.
; Make them all case-sensitive. Use space as the only trigger character.
#Hotstring C Z
#Hotstring EndChars `s

; WARNING: You have to define longer hotstrings before shorter ones.
; Otherwise AHK will prioritize expanding the shorter one since defined first.
::iv!::I haven't
::ivb::I've been
::iv!b::I haven't been 
::ur::you're
::ur!::you're not
::m+::many 
::tt::that
::ts::this
::tn::than
::tm::them
::ty::they
::tyr::they're
::tyr!::they're not
::wer::we're
::wer!::we're not
::ct::can't
::c!::cannot
::hv::have
::bn::been
::hvt::haven't 
::hv!::have not
::un-::unless
::ut::until
::fr::from
::afr::away from
::tw::toward
::af::after
::ab::about
::b4::before
::2d::today
::2m::tomorrow
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
::uvb::you've been
::sth::something
::sthe::something else
::nG::nothing
::nGe::nothing else
::s1::someone
::a1::anyone
::n1::no one
::fA::faction
::gG::going
::gG2::going to
::t=::test
::,C::concise
::,curC::concurence
::,qC::consequence
::,qV::consequtive
::,t=::contest
::,fluC::confluence
::,trast::contrast
::,trastG::constrasting
::,venT::convention
::?::question
::?s::questions
::?d::questioned
::?G::questioning
::?B::questionable
::t?::think
::t?G::thinking
::t?+::thoughtful
::t?+N::thoughtfulness
::^t?G::overthinking
::_takeG::undertaking
::thank+::thankful
::thank+y::thankfully
::/G::leaning
::c/::clean
::c/s::cleans
::c/d::cleaned
::c/r::cleaner
::c/G::cleaning
::_st&::understand
::_st&G::understanding
::st&G::standing
::t=M::testament
::reA::reaction
::bB2::be able to
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
::Xform::Send("transform")
::XformT::transformation
::Xl8::translate
::Xl8T::translation
::XG::crossing
::XportaT::transportation
::XportG::transporting
::+::more
::-::less
::_::under
::^::over
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
::v::very
::w::with
::AA::A
::A::action
::B::able
::G::thing
::aa::and
::im::I'm
:?:im!::I'm not
::iv::I've

; END

RemoveToolTip() => ToolTip()

; Terminate this keystroke handler. End this mode.
LControl & Escape:: {
	ToolTip("Shorthand mode OFF")
	Suspend(true)
	SetTimer(RemoveToolTip, -2000)
	Sleep(2000)
	ExitApp
}

