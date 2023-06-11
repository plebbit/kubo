package libp2p

import (
	pubsub "github.com/libp2p/go-libp2p-pubsub"
	"github.com/libp2p/go-libp2p/core/discovery"
	"github.com/libp2p/go-libp2p/core/host"
	"go.uber.org/fx"

	"github.com/ipfs/kubo/core/node/helpers"
	pubsubPlebbitValidator "github.com/plebbit/go-libp2p-pubsub-plebbit-validator"
)

func FloodSub(pubsubOptions ...pubsub.Option) interface{} {
	return func(mctx helpers.MetricsCtx, lc fx.Lifecycle, host host.Host, disc discovery.Discovery) (service *pubsub.PubSub, err error) {
		return pubsub.NewFloodSub(helpers.LifecycleCtx(mctx, lc), host, append(pubsubOptions, pubsub.WithDiscovery(disc))...)
	}
}

func GossipSub(pubsubOptions ...pubsub.Option) interface{} {
	return func(mctx helpers.MetricsCtx, lc fx.Lifecycle, host host.Host, disc discovery.Discovery) (service *pubsub.PubSub, err error) {
		validator := pubsubPlebbitValidator.NewValidator(host)
    	peerScoreParams := pubsubPlebbitValidator.NewPeerScoreParams(validator)
		return pubsub.NewGossipSub(helpers.LifecycleCtx(mctx, lc), host, append(
			pubsubOptions,
			pubsub.WithDefaultValidator(validator.Validate),
			pubsub.WithMessageIdFn(pubsubPlebbitValidator.MessageIdFn),
        	pubsub.WithPeerScore(&peerScoreParams, &pubsubPlebbitValidator.PeerScoreThresholds),
			pubsub.WithDiscovery(disc),
			pubsub.WithFloodPublish(true))...,
		)
	}
}
