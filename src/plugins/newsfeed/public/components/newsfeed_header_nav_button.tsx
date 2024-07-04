/*
 * Copyright Elasticsearch B.V. and/or licensed to Elasticsearch B.V. under one
 * or more contributor license agreements. Licensed under the Elastic License
 * 2.0 and the Server Side Public License, v 1; you may not use this file except
 * in compliance with, at your election, the Elastic License 2.0 or the Server
 * Side Public License, v 1.
 */

import React, { useState, useEffect, useMemo, useCallback, useRef } from 'react';
import { EuiHeaderSectionItemButton, EuiIcon } from '@elastic/eui';
import { i18n } from '@kbn/i18n';
import { Observable } from 'rxjs';
import useObservable from 'react-use/lib/useObservable';
import type { NewsfeedApi } from '../lib/api';
import { NewsfeedFlyout } from './flyout_list';
import { FetchResult } from '../types';

export interface INewsfeedContext {
  setFlyoutVisible: React.Dispatch<React.SetStateAction<boolean>>;
  newsFetchResult: FetchResult | void | null;
}

export const NewsfeedContext = React.createContext({} as INewsfeedContext);

export interface Props {
  newsfeedApi: NewsfeedApi;
  hasCustomBranding$: Observable<boolean>;
}

export const NewsfeedNavButton = ({ newsfeedApi, hasCustomBranding$ }: Props) => {
  const [flyoutVisible, setFlyoutVisible] = useState<boolean>(false);
  const [newsFetchResult, setNewsFetchResult] = useState<FetchResult | null | void>(null);
  const hasCustomBranding = useObservable(hasCustomBranding$, false);
  const hasNew = useMemo(() => {
    return newsFetchResult ? newsFetchResult.hasNew : false;
  }, [newsFetchResult]);

  const buttonRef = useRef<HTMLButtonElement | null>(null);
  const setButtonRef = (node: HTMLButtonElement | null) => (buttonRef.current = node);

  useEffect(() => {
    const subscription = newsfeedApi.fetchResults$.subscribe((results) => {
      setNewsFetchResult(results);
    });
    return () => subscription.unsubscribe();
  }, [newsfeedApi]);

  const showFlyout = useCallback(() => {
    if (newsFetchResult) {
      newsfeedApi.markAsRead(newsFetchResult.feedItems.map((item) => item.hash));
    }
    setFlyoutVisible(!flyoutVisible);
  }, [newsfeedApi, newsFetchResult, flyoutVisible]);

  return (
    <NewsfeedContext.Provider value={{ setFlyoutVisible, newsFetchResult }}>
      <>
      </>
    </NewsfeedContext.Provider>
  );
};
