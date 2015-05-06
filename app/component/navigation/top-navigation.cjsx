React                 = require 'react'
Link                  = require 'react-router/lib/components/Link'
Icon                  = require '../icon/icon'

class TopNavigation extends React.Component
  render: ->
    <div className="fixed">
      <nav className="top-bar">
        <section className="title">
          <Link to="index">
            <Icon img={'icon-icon_HSL-logo'} className="logo"/>
            <span className="title">Reittiopas Demo</span>
          </Link>
        </section>
        {@props.children}
      </nav>
    </div>

module.exports = TopNavigation