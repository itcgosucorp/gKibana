/*
 * Copyright Elasticsearch B.V. and/or licensed to Elasticsearch B.V. under one
 * or more contributor license agreements. Licensed under the Elastic License
 * 2.0; you may not use this file except in compliance with the Elastic License
 * 2.0.
 */

import { i18n } from '@kbn/i18n';
import { CANVAS, INSTAGRAM } from './constants';

export const LibStrings = {
  Palettes: {
    getEarthTones: () =>
      i18n.translate('xpack.canvas.lib.palettes.earthTonesLabel', {
        defaultMessage: 'Earth Tones',
      }),
    getCanvas: () =>
      i18n.translate('xpack.canvas.lib.palettes.canvasLabel', {
        defaultMessage: '{CANVAS}',
        values: {
          CANVAS,
        },
      }),

    getColorBlind: () =>
      i18n.translate('xpack.canvas.lib.palettes.colorBlindLabel', {
        defaultMessage: 'Color Blind',
      }),

    getElasticTeal: () =>
      i18n.translate('xpack.canvas.lib.palettes.elasticTealLabel', {
        defaultMessage: 'gExplorer Teal',
      }),

    getElasticBlue: () =>
      i18n.translate('xpack.canvas.lib.palettes.elasticBlueLabel', {
        defaultMessage: 'gExplorer Blue',
      }),

    getElasticYellow: () =>
      i18n.translate('xpack.canvas.lib.palettes.elasticYellowLabel', {
        defaultMessage: 'gExplorer Yellow',
      }),

    getElasticPink: () =>
      i18n.translate('xpack.canvas.lib.palettes.elasticPinkLabel', {
        defaultMessage: 'gExplorer Pink',
      }),

    getElasticGreen: () =>
      i18n.translate('xpack.canvas.lib.palettes.elasticGreenLabel', {
        defaultMessage: 'gExplorer Green',
      }),

    getElasticOrange: () =>
      i18n.translate('xpack.canvas.lib.palettes.elasticOrangeLabel', {
        defaultMessage: 'gExplorer Orange',
      }),

    getElasticPurple: () =>
      i18n.translate('xpack.canvas.lib.palettes.elasticPurpleLabel', {
        defaultMessage: 'gExplorer Purple',
      }),

    getGreenBlueRed: () =>
      i18n.translate('xpack.canvas.lib.palettes.greenBlueRedLabel', {
        defaultMessage: 'Green, Blue, Red',
      }),

    getYellowGreen: () =>
      i18n.translate('xpack.canvas.lib.palettes.yellowGreenLabel', {
        defaultMessage: 'Yellow, Green',
      }),

    getYellowBlue: () =>
      i18n.translate('xpack.canvas.lib.palettes.yellowBlueLabel', {
        defaultMessage: 'Yellow, Blue',
      }),

    getYellowRed: () =>
      i18n.translate('xpack.canvas.lib.palettes.yellowRedLabel', {
        defaultMessage: 'Yellow, Red',
      }),

    getInstagram: () =>
      i18n.translate('xpack.canvas.lib.palettes.instagramLabel', {
        defaultMessage: '{INSTAGRAM}',
        values: {
          INSTAGRAM,
        },
      }),
  },
};
